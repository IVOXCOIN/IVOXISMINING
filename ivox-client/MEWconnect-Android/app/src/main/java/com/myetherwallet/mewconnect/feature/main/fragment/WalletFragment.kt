package com.myetherwallet.mewconnect.feature.main.fragment

import android.app.Activity
import android.app.AlertDialog
import android.content.DialogInterface
import android.os.Bundle
import android.os.Handler
import android.support.design.widget.CoordinatorLayout
import android.support.v7.widget.LinearLayoutManager
import android.support.v7.widget.RecyclerView
import android.util.Log
import android.view.View
import android.view.View.*
import android.view.ViewGroup
import com.mikepenz.materialdrawer.Drawer
import com.myetherwallet.mewconnect.R
import com.myetherwallet.mewconnect.content.data.BalanceMethod
import com.myetherwallet.mewconnect.content.data.MessageToSign
import com.myetherwallet.mewconnect.content.data.Network
import com.myetherwallet.mewconnect.content.data.Transaction
import com.myetherwallet.mewconnect.core.di.ApplicationComponent
import com.myetherwallet.mewconnect.core.extenstion.observe
import com.myetherwallet.mewconnect.core.extenstion.viewModel
import com.myetherwallet.mewconnect.core.persist.prefenreces.PreferencesManager
import com.myetherwallet.mewconnect.core.platform.NetworkHandler
import com.myetherwallet.mewconnect.core.ui.callback.EmptyTextWatcher
import com.myetherwallet.mewconnect.core.ui.fragment.BaseViewModelFragment
import com.myetherwallet.mewconnect.core.utils.CardBackgroundHelper
import com.myetherwallet.mewconnect.feature.backup.fragment.BackUpWalletFragment
import com.myetherwallet.mewconnect.feature.buy.fragment.BuyFragment
import com.myetherwallet.mewconnect.feature.main.adapter.WalletListAdapter
import com.myetherwallet.mewconnect.feature.main.data.WalletBalance
import com.myetherwallet.mewconnect.feature.main.data.WalletData
import com.myetherwallet.mewconnect.feature.main.dialog.BackupWarningDialog
import com.myetherwallet.mewconnect.feature.main.dialog.BalanceMethodDialog
import com.myetherwallet.mewconnect.feature.main.dialog.ChooseNetworkDialog
import com.myetherwallet.mewconnect.feature.main.receiver.NetworkStateReceiver
import com.myetherwallet.mewconnect.feature.main.utils.WalletSizingUtils
import com.myetherwallet.mewconnect.feature.main.view.behavior.WalletScrollBehavior
import com.myetherwallet.mewconnect.feature.main.viewmodel.WalletViewModel
import com.myetherwallet.mewconnect.feature.register.utils.ScrollWatcher
import com.myetherwallet.mewconnect.feature.scan.fragment.ConfirmTransactionFragment
import com.myetherwallet.mewconnect.feature.scan.fragment.ScanFragment
import com.myetherwallet.mewconnect.feature.scan.fragment.SignMessageFragment
import kotlinx.android.synthetic.main.fragment_wallet.*
import kotlinx.android.synthetic.main.view_wallet_card.*
import java.math.BigDecimal
import java.util.concurrent.TimeUnit
import javax.inject.Inject

import com.mikepenz.materialdrawer.DrawerBuilder
import com.mikepenz.materialdrawer.model.DividerDrawerItem
import com.mikepenz.materialdrawer.model.PrimaryDrawerItem
import com.mikepenz.materialdrawer.model.interfaces.IDrawerItem
import com.myetherwallet.mewconnect.core.utils.HexUtils
import com.myetherwallet.mewconnect.feature.main.activity.MainActivity

/**
 * Created by BArtWell on 11.07.2018.
 */

class WalletFragment : BaseViewModelFragment() {

    companion object {

        private val BACKUP_WARNING_DELAY = TimeUnit.HOURS.toMillis(12)
        private val PRIVATE_KEY_BACKUP_WARNING_DELAY = TimeUnit.HOURS.toMillis(48)

        fun newInstance() = WalletFragment()
    }

    @Inject
    lateinit var preferences: PreferencesManager
    @Inject
    lateinit var networkHandler: NetworkHandler
    private lateinit var viewModel: WalletViewModel
    private val networkStateReceiver = NetworkStateReceiver(::setConnectedStatus)
    private val handler = Handler()
    private val adapter = WalletListAdapter()
    private lateinit var address: String
    private lateinit var scrollWatcher: ScrollWatcher
    private var scrollThreshold = 0
    private var shouldScrollToThreshold = false

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        ///////////////////////

        (activity as MainActivity).setupDrawer(multiselect_toolbar)

        //////////////////////

        scrollWatcher = ScrollWatcher(wallet_list)
        scrollWatcher.scrollStateListener = ::onScrollStateChanged

        val layoutParams = wallet_scrollable_container.layoutParams as CoordinatorLayout.LayoutParams
        layoutParams.behavior = WalletScrollBehavior(requireContext(), null, scrollWatcher)
        wallet_scrollable_container.layoutParams = layoutParams


        scrollThreshold = WalletSizingUtils.calculateScrollThreshold(view)

        wallet_toolbar.y = WalletSizingUtils.getToolbarMargin(view).toFloat()

        wallet_header.onUpdateClickListener = { load() }
        init()
    }

    private fun init() {
        wallet_loading.visibility = VISIBLE
        wallet_header.visibility = INVISIBLE

        viewModel = viewModel(viewModelFactory) {
            observe(walletData, ::onBalancesLoaded)
        }

        viewModel.activity = this.activity!!

        setupWalletEmptyView()

        populateWithEmpties()

        address = preferences.getCurrentWalletPreferences().getWalletAddress()
        wallet_card.setAddress(address)

        val layoutManager = LinearLayoutManager(context)
        wallet_list.layoutManager = layoutManager
        wallet_list.adapter = adapter

        //wallet_scan_to_connect.setOnClickListener { addFragment(ScanFragment.newInstance()) }
        wallet_status_disconnect.setOnClickListener {
            viewModel.disconnect()
            setConnectedStatus()
        }

        wallet_card.onBackupClickListener = { addFragment(BackUpWalletFragment.newInstance()) }
        wallet_card.onShareClickListener = { addFragment(AddressFragment.newInstance()) }

        wallet_toolbar.onInfoClickListener = { addFragment(InfoFragment.newInstance()) }
        wallet_toolbar.onNetworkClickListener = ::showNetworkMenu

        //view_tokens.setOnClickListener { addFragment(TokensFragment.newInstance()) }
        //transfer_tokens.setOnClickListener { addFragment(TransactionFragment.newInstance()) }

        // Auto scroll on search start
        wallet_header.onEnterSearchModeListener = {
            if (scrollWatcher.scrollPosition < scrollThreshold) {
                wallet_list.smoothScrollBy(0, scrollThreshold - scrollWatcher.scrollPosition)
            }
        }
        wallet_header.setTextChangedListener(object : EmptyTextWatcher {
            override fun onTextChanged(s: CharSequence, start: Int, before: Int, count: Int) {
                if (start == 0 && before == 0 && count == 0) {
                    return
                }
                // Wait for next character or search
                handler.removeCallbacksAndMessages(null)
                handler.postDelayed({ adapter.filter?.filter(s, ::onListFiltered) }, 100)
            }
        })

        //CardBackgroundHelper.setImage(wallet_card_background, preferences.applicationPreferences.getCurrentNetwork())

        if (address.isEmpty()) {
            return
        }

        wallet_list.isLayoutFrozen = true
        wallet_list.isVerticalScrollBarEnabled = false
        wallet_list.isNestedScrollingEnabled = false
        wallet_list.alpha = 0.0f

        wallet_header.alpha = 1.0f
        wallet_header.isClickable = false

        wallet_header.setSearchVisible(false)


        load()
    }

    private fun setupWalletEmptyView() {
        view?.let {
            val listMargin = WalletSizingUtils.calculateListMargin(it)
            val layoutParamsEmpty = wallet_empty.layoutParams as ViewGroup.MarginLayoutParams
            layoutParamsEmpty.topMargin = listMargin
            wallet_empty.layoutParams = layoutParamsEmpty
            val layoutParamsLoading = wallet_loading.layoutParams as ViewGroup.MarginLayoutParams
            layoutParamsLoading.topMargin = listMargin
            wallet_loading.layoutParams = layoutParamsLoading
        }
    }

    private fun load() {
        wallet_header.setUpdating(true)
        viewModel.loadData(preferences.getCurrentWalletPreferences(),
                            preferences.applicationPreferences.getCurrentNetwork(),
                            address,
                            context!!.getString(preferences.applicationPreferences.getBalanceMethod().shortName))
    }

    private fun populateWithEmpties() {
        if (wallet_card.isEmpty()) {
            wallet_header.setBalance(BigDecimal.ZERO)
            wallet_header.setSearchVisible(false)
            wallet_card.setBalance(WalletBalance(BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO), preferences.applicationPreferences.getCurrentNetwork())
        }
    }

    private fun onBalancesLoaded(data: WalletData?) {
        if (data?.isFromCache == false) {
            wallet_header.setUpdating(false)
        }
        if (address.isEmpty()) {
            return
        }
        data?.let {
            wallet_loading.visibility = GONE
            wallet_header.visibility = VISIBLE

            if (data.items.isEmpty()) {
                wallet_empty.visibility = VISIBLE
                wallet_header.setBalance(BigDecimal.ZERO)
                wallet_header.setSearchVisible(false)
            } else {
                wallet_empty.visibility = GONE
                wallet_header.setSearchVisible(false)

                val items = it.items
                adapter.items = items.toMutableList()
                adapter.notifyDataSetChanged()
                wallet_header.setBalance(items.fold(BigDecimal.ZERO) { acc, item ->
                    acc.add(item.valueUsd ?: BigDecimal.ZERO)
                })
                wallet_header.setHint(getString(R.string.wallet_header_search_hint, items.size))
            }

            val balance = it.balance
            wallet_card.setBalance(balance, preferences.applicationPreferences.getCurrentNetwork())

            wallet_toolbar.setBalance(balance.value)
            wallet_toolbar.setNetwork(preferences.applicationPreferences.getCurrentNetwork())
            wallet_toolbar.setBalanceMethod(preferences.applicationPreferences.getBalanceMethod())

            val method = context!!.getString(preferences.applicationPreferences.getBalanceMethod().shortName)

            if(method == "IVOX"){
                wallet_card.setCurrency("IVOX TOKEN")
            } else {

                wallet_card.setCurrency("ETHER")
            }


            balance.stockPrice?.let { stockPrice ->
                wallet_toolbar.onBuyClickListener = { addFragment(BuyFragment.newInstance(stockPrice)) }
            }

            showPrivateKeyWarning(balance.value)
            showBackupWarning(balance.value)
        }
    }

    private fun showPrivateKeyWarning(balance: BigDecimal){
        if (!(balance > BigDecimal.ZERO &&
                preferences.applicationPreferences.getCurrentNetwork() == Network.MAIN &&
                !preferences.applicationPreferences.isBackedUp() &&
                System.currentTimeMillis() - preferences.applicationPreferences.getBackupWarningTime() > BACKUP_WARNING_DELAY))
        {
            if (!preferences.applicationPreferences.isPrivateKeyBackedUp() &&
                    System.currentTimeMillis() - preferences.applicationPreferences.getPrivateKeyBackupWarningTime() > PRIVATE_KEY_BACKUP_WARNING_DELAY){

                preferences.applicationPreferences.setPrivateKeyBackupWarningTime()


                val privateBuilder = AlertDialog.Builder(activity!!)

                privateBuilder.setTitle(activity!!.getText(R.string.update_register_user_continue))

                privateBuilder.setMessage(activity!!.getText(R.string.update_register_user_private_key))

                privateBuilder.setPositiveButton("OK"){dialog, which ->

                }

                val privateDialog: AlertDialog = privateBuilder.create()

                privateDialog.setOnShowListener(DialogInterface.OnShowListener {
                    privateDialog.getButton(AlertDialog.BUTTON_POSITIVE).setBackgroundColor(resources.getColor(R.color.blue))
                    privateDialog.getButton(AlertDialog.BUTTON_POSITIVE).setTextColor(resources.getColor(R.color.white))
                })

                privateDialog.show()
            }
        }
    }

    private fun showBackupWarning(balance: BigDecimal) {
        if (balance > BigDecimal.ZERO &&
                preferences.applicationPreferences.getCurrentNetwork() == Network.MAIN &&
                !preferences.applicationPreferences.isBackedUp() &&
                System.currentTimeMillis() - preferences.applicationPreferences.getBackupWarningTime() > BACKUP_WARNING_DELAY) {
            preferences.applicationPreferences.setBackupWarningTime()
            val dialog = BackupWarningDialog.newInstance()
            dialog.listener = { addFragment(BackUpWalletFragment.newInstance()) }
            dialog.show(childFragmentManager)
        }
    }

    override fun onResume() {
        super.onResume()
        setConnectedStatus()
        networkStateReceiver.register(requireContext())
        viewModel.setOnDisconnectListener {
            activity?.runOnUiThread {
                setConnectedStatus()
            }
        }
    }

    override fun onPause() {
        viewModel.setOnDisconnectListener(null)
        networkStateReceiver.unregister(requireContext())
        super.onPause()
    }

    private fun setConnectedStatus() {
        when {
            networkHandler.isConnected != true -> {
                wallet_status_container.visibility = GONE
                wallet_offline_container.visibility = VISIBLE
                //wallet_scan_to_connect.visibility = GONE
            }
            viewModel.checkConnected() -> {
                viewModel.setOnTransactionListener { activity?.runOnUiThread { openConfirmFragment(it) } }
                viewModel.setOnMessageListener { activity?.runOnUiThread { openSignMessageFragment(it) } }
                wallet_status_container.visibility = VISIBLE
                wallet_offline_container.visibility = GONE
                //wallet_scan_to_connect.visibility = GONE
            }
            else -> {
                wallet_status_container.visibility = GONE
                wallet_offline_container.visibility = GONE
                //wallet_scan_to_connect.visibility = VISIBLE
            }
        }
    }

    private fun openConfirmFragment(transaction: Transaction) {
        addOrReplaceFragment(ConfirmTransactionFragment.newInstance(transaction, viewModel.walletData.value?.balance?.stockPrice), ConfirmTransactionFragment.TAG)
    }

    private fun openSignMessageFragment(message: MessageToSign) {
        addOrReplaceFragment(SignMessageFragment.newInstance(message), SignMessageFragment.TAG)
    }

    private fun showNetworkMenu() {
        val dialog = BalanceMethodDialog()
        dialog.listener = {
            preferences.applicationPreferences.setBalanceMethod(it)
            if (preferences.getCurrentWalletPreferences().isWalletExists()) {
                wallet_header.clearSearch()
                viewModel.disconnect()
                setConnectedStatus()
                init()
            } else {
                replaceFragment(IntroFragment.newInstance())
            }
        }
        dialog.show(childFragmentManager)
    }

    private fun onScrollStateChanged(state: Int, position: Int) {
        // Auto open/close card view
        if (state == RecyclerView.SCROLL_STATE_IDLE) {
            if (shouldScrollToThreshold) {
                shouldScrollToThreshold = false
                scrollAfterFilter()
            } else {
                if (position in 1..(scrollThreshold - 1)) {
                    if (position < scrollThreshold / 2) {
                        wallet_list.smoothScrollBy(0, -position)
                    } else if (position > scrollThreshold / 2 && position < scrollThreshold) {
                        wallet_list.smoothScrollBy(0, scrollThreshold - position)
                    }
                }
            }
        }
    }

    private fun onListFiltered(count: Int) {
        if (scrollWatcher.scrollState == RecyclerView.SCROLL_STATE_IDLE) {
            scrollAfterFilter()
        } else {
            shouldScrollToThreshold = true
        }
    }

    private fun scrollAfterFilter() {
        handler.postDelayed({ wallet_list.scrollBy(0, scrollThreshold - scrollWatcher.request()) }, 100)
    }

    override fun inject(appComponent: ApplicationComponent) {
        appComponent.inject(this)
    }

    override fun layoutId() = R.layout.fragment_wallet
}