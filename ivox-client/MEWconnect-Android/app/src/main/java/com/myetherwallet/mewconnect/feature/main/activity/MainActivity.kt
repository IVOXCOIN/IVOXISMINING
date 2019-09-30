package com.myetherwallet.mewconnect.feature.main.activity

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.support.v4.app.Fragment
import android.support.v4.app.FragmentManager
import android.support.v4.app.FragmentTransaction
import android.support.v7.widget.RecyclerView
import android.support.v7.widget.Toolbar
import android.util.Log
import android.view.View
import com.mikepenz.materialdrawer.AccountHeaderBuilder
import com.mikepenz.materialdrawer.Drawer
import com.mikepenz.materialdrawer.DrawerBuilder
import com.mikepenz.materialdrawer.model.DividerDrawerItem
import com.mikepenz.materialdrawer.model.PrimaryDrawerItem
import com.mikepenz.materialdrawer.model.ProfileDrawerItem
import com.mikepenz.materialdrawer.model.interfaces.IDrawerItem

import com.myetherwallet.mewconnect.R
import com.myetherwallet.mewconnect.core.di.ApplicationComponent
import com.myetherwallet.mewconnect.core.persist.prefenreces.PreferencesManager
import com.myetherwallet.mewconnect.core.ui.activity.BaseDiActivity
import com.myetherwallet.mewconnect.core.ui.fragment.BaseFragment
import com.myetherwallet.mewconnect.feature.auth.fragment.AuthFragment
import com.myetherwallet.mewconnect.feature.buy.fragment.BuyFragment
import com.myetherwallet.mewconnect.feature.main.fragment.*
import com.myetherwallet.mewconnect.feature.scan.service.SocketService
import javax.inject.Inject

/**
 * Created by BArtWell on 30.06.2018.
 */

class MainActivity : BaseDiActivity() {

    companion object {
        fun createIntent(context: Context) = Intent(context, MainActivity::class.java)
    }

    @Inject
    lateinit var preferences: PreferencesManager

    private var drawer: Drawer? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        if (preferences.getCurrentWalletPreferences().isWalletExists()) {
            replaceFragment(AuthFragment.newInstance())
        } else {
            replaceFragment(IntroFragment.newInstance())
        }

        setStatusBarColor()

    }

    fun setupDrawer(toolbar: Toolbar){

        val headerResult = AccountHeaderBuilder()
                .withActivity(this as Activity)
                .withHeaderBackground(R.color.blue)
                .addProfiles(
                    ProfileDrawerItem()
                            .withName("Ivox Wallet")
                            .withIcon(getResources().getDrawable(R.drawable.ethereum_logo))
                )
                .build()

        var item1 = PrimaryDrawerItem().withIdentifier(1).withName(R.string.drawer_item_home)
        //var item2 = PrimaryDrawerItem().withIdentifier(2).withName(R.string.drawer_item_buy)
        var item3 = PrimaryDrawerItem().withIdentifier(3).withName(R.string.drawer_item_tokens)
        var item4 = PrimaryDrawerItem().withIdentifier(4).withName(R.string.drawer_item_transfer)
        var item5 = PrimaryDrawerItem().withIdentifier(5).withName(R.string.drawer_item_info)


        drawer = DrawerBuilder()
                .withActivity(this as Activity)
                .withAccountHeader(headerResult)
                .withToolbar(toolbar)
                .addDrawerItems(
                        item1,
                        DividerDrawerItem(),
                        //item2,
                        //DividerDrawerItem(),
                        item3,
                        DividerDrawerItem(),
                        item4,
                        DividerDrawerItem(),
                        item5
                )
                .withOnDrawerItemClickListener(object : Drawer.OnDrawerItemClickListener {
                    override fun onItemClick(view: View,
                                             position: Int,
                                             drawerItem: IDrawerItem<out Any?, out RecyclerView.ViewHolder>?): Boolean {
                        Log.d("DRAWER", "Clicked! " + position.toString())
                        if(drawerItem!!.identifier == 1.toLong()){

                            replaceFragment(WalletFragment.newInstance())

                        } else if(drawerItem!!.identifier == 2.toLong()){

                            //replaceFragment(BuyFragment.newInstance())

                        } else if(drawerItem!!.identifier == 3.toLong()){

                            replaceFragment(TokensFragment.newInstance())

                        } else if(drawerItem!!.identifier == 4.toLong()){

                            replaceFragment(TransactionFragment.newInstance())

                        } else if(drawerItem!!.identifier == 5.toLong()){

                            replaceFragment(InfoFragment.newInstance())

                        }

                        //drawer?.setSelection(drawerItem)
                        drawer?.closeDrawer()
                        return true
                    }
                })
                .build()
    }

    override fun onResume() {
        super.onResume()
        SocketService.start(this)
    }

    override fun onPause() {
        super.onPause()
        SocketService.shutdownDelayed(this)
    }

    fun replaceFragment(fragment: Fragment) {
        val fragmentManager = supportFragmentManager
        fragmentManager.popBackStack(null, FragmentManager.POP_BACK_STACK_INCLUSIVE)
        val fragmentTransaction = fragmentManager.beginTransaction()
        fragmentTransaction.replace(R.id.main_fragment_container, fragment, fragment.toString())
        fragmentTransaction.setTransition(FragmentTransaction.TRANSIT_FRAGMENT_OPEN)
        fragmentTransaction.setTransition(FragmentTransaction.TRANSIT_FRAGMENT_CLOSE)
        fragmentTransaction.commit()
    }

    fun addFragment(fragment: Fragment) {
        val fragmentManager = supportFragmentManager
        val fragmentTransaction = fragmentManager.beginTransaction()
        fragmentTransaction.replace(R.id.main_fragment_container, fragment, fragment.toString())
        fragmentTransaction.setTransition(FragmentTransaction.TRANSIT_FRAGMENT_OPEN)
        fragmentTransaction.setTransition(FragmentTransaction.TRANSIT_FRAGMENT_CLOSE)
        fragmentTransaction.addToBackStack(null)
        fragmentTransaction.commit()
    }

    fun addOrReplaceFragment(fragment: Fragment, tag: String) {
        val fragmentManager = supportFragmentManager
        val fragmentTransaction = fragmentManager.beginTransaction()
        val previous = fragmentManager.findFragmentByTag(tag)
        if (previous == null) {
            fragmentTransaction.setTransition(FragmentTransaction.TRANSIT_FRAGMENT_OPEN)
            fragmentTransaction.setTransition(FragmentTransaction.TRANSIT_FRAGMENT_CLOSE)
        } else {
            fragmentManager.popBackStackImmediate(tag, FragmentManager.POP_BACK_STACK_INCLUSIVE)
        }
        fragmentTransaction.replace(R.id.main_fragment_container, fragment, tag)
        fragmentTransaction.addToBackStack(tag)
        fragmentTransaction.commit()
    }

    override fun onBackPressed() {
        val fragment = supportFragmentManager.findFragmentById(R.id.main_fragment_container)
        if (fragment !is BaseFragment || !fragment.onBackPressed()) {
            super.onBackPressed()
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        for (fragment in supportFragmentManager.fragments) {
            fragment.onActivityResult(requestCode, resultCode, data)
        }
    }

    override fun inject(appComponent: ApplicationComponent) {
        appComponent.inject(this)
    }
}

