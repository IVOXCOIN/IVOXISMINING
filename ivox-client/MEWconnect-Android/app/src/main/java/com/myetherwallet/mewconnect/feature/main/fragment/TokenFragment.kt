package com.myetherwallet.mewconnect.feature.main.fragment

import android.os.Bundle
import android.support.v7.widget.Toolbar
import android.view.MenuItem
import android.view.View
import com.myetherwallet.mewconnect.R
import com.myetherwallet.mewconnect.core.di.ApplicationComponent
import com.myetherwallet.mewconnect.core.ui.fragment.BaseDiFragment
import com.myetherwallet.mewconnect.feature.main.activity.MainActivity
import com.myetherwallet.mewconnect.feature.main.adapter.TokenListAdapter
import kotlinx.android.synthetic.main.fragment_tokens.*

class TokenFragment : BaseDiFragment(), Toolbar.OnMenuItemClickListener {

    companion object {

        fun newInstance(paypalId: String,
                        id: String,
                        wallet: String,
                        currency: String,
                        date: String,
                        source: String,
                        destination: String,
                        value: String,
                        purchase: String,
                        status: String): TokenFragment {

            val fragment = TokenFragment()
            val arguments = Bundle()

            arguments.putSerializable("paypal_id", paypalId)
            arguments.putSerializable("id", id)
            arguments.putSerializable("wallet", wallet)
            arguments.putSerializable("currency", currency)
            arguments.putSerializable("date", date)
            arguments.putSerializable("source", source)
            arguments.putSerializable("destination", destination)
            arguments.putSerializable("value", value)
            arguments.putSerializable("purchase", purchase)
            arguments.putSerializable("status", status)

            fragment.arguments = arguments
            return fragment
        }
    }

    private var paypalId: String = ""
    private var id: String = ""
    private var wallet: String = ""
    private var currency: String = ""
    private var date: String = ""
    private var source: String = ""
    private var destination: String = ""
    private var value: String = ""
    private var purchase: String = ""
    private var status: String = ""

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        (activity as MainActivity).setupDrawer(tokens_toolbar)


        paypalId = arguments!!.getSerializable("paypal_id") as String
        id = arguments!!.getSerializable("id") as String
        wallet = arguments!!.getSerializable("wallet") as String
        currency = arguments!!.getSerializable("currency") as String
        date = arguments!!.getSerializable("date") as String
        source = arguments!!.getSerializable("source") as String
        destination = arguments!!.getSerializable("destination") as String
        value = arguments!!.getSerializable("value") as String
        purchase = arguments!!.getSerializable("purchase") as String
        status = arguments!!.getSerializable("status") as String

        load()

    }

    private fun load(){
        collect()
    }

    private fun collect() {
        this.activity?.runOnUiThread(java.lang.Runnable {

            val titles = mutableListOf<String>()
            val strings   = mutableListOf<String>()

            titles.add(activity!!.getText(R.string.transfer_paypal_title).toString())
            titles.add(activity!!.getText(R.string.transfer_ethereum_title).toString())
            titles.add(activity!!.getText(R.string.transfer_wallet_title).toString())
            titles.add(activity!!.getText(R.string.transfer_currency_title).toString())
            titles.add(activity!!.getText(R.string.transfer_date_title).toString())
            titles.add(activity!!.getText(R.string.transfer_date_source).toString())
            titles.add(activity!!.getText(R.string.transfer_date_destination).toString())
            titles.add(activity!!.getText(R.string.transfer_value_title).toString())
            titles.add(activity!!.getText(R.string.transfer_purchase_title).toString())
            titles.add(activity!!.getText(R.string.transfer_status_title).toString())

            strings.add(paypalId)
            strings.add(id)
            strings.add(wallet)
            strings.add(currency)
            strings.add(date)
            strings.add(source)
            strings.add(destination)
            strings.add(value)
            strings.add(purchase)
            strings.add(status)

            val tokenListAdapter = TokenListAdapter(this.activity!!, titles, strings)

            tokens_list.adapter = tokenListAdapter
        })

    }

    override fun onMenuItemClick(menuItem: MenuItem): Boolean {
        close()
        return true
    }

    override fun inject(appComponent: ApplicationComponent) {
        appComponent.inject(this)
    }

    override fun layoutId() = R.layout.fragment_tokens
}