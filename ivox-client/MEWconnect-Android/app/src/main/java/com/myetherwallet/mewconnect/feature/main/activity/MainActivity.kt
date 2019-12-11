package com.myetherwallet.mewconnect.feature.main.activity

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.IntentSender
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

import android.support.design.widget.Snackbar
import android.support.v4.content.ContextCompat
import android.widget.Toast
import com.google.android.play.core.appupdate.AppUpdateManager
import com.google.android.play.core.appupdate.AppUpdateManagerFactory
import com.google.android.play.core.install.InstallState
import com.google.android.play.core.install.InstallStateUpdatedListener
import com.google.android.play.core.install.model.AppUpdateType
import com.google.android.play.core.install.model.InstallStatus
import com.google.android.play.core.install.model.UpdateAvailability

/**
 * Created by BArtWell on 30.06.2018.
 */

class MainActivity : BaseDiActivity() {

    private val appUpdateManager: AppUpdateManager by lazy { AppUpdateManagerFactory.create(this) }
    private val appUpdatedListener: InstallStateUpdatedListener by lazy {
        object : InstallStateUpdatedListener {
            override fun onStateUpdate(installState: InstallState) {
                when {
                    installState.installStatus() == InstallStatus.DOWNLOADED -> popupSnackbarForCompleteUpdate()
                    installState.installStatus() == InstallStatus.INSTALLED -> appUpdateManager.unregisterListener(this)
                    else -> Log.d("com.ivox.ivoxis","InstallStateUpdatedListener: state: " + installState.installStatus().toString())
                }
            }
        }
    }

    companion object {
        private const val APP_UPDATE_REQUEST_CODE = 1991

        fun createIntent(context: Context) = Intent(context, MainActivity::class.java)
    }

    @Inject
    lateinit var preferences: PreferencesManager

    private var drawer: Drawer? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        if (preferences.getCurrentWalletPreferences().isWalletExists()) {

            if(preferences.applicationPreferences.isRegistered()){
                replaceFragment(AuthFragment.newInstance())
            } else {
                replaceFragment(UserRegisterFragment.newInstance())
            }

        } else {
            replaceFragment(IntroFragment.newInstance())
        }

        setStatusBarColor()

        checkForAppUpdate()
    }

    private fun checkForAppUpdate() {
        // Returns an intent object that you use to check for an update.
        val appUpdateInfoTask = appUpdateManager.appUpdateInfo

        // Checks that the platform will allow the specified type of update.
        appUpdateInfoTask.addOnSuccessListener { appUpdateInfo ->

            val updateAvailability = appUpdateInfo.updateAvailability()
            if (updateAvailability == UpdateAvailability.UPDATE_AVAILABLE) {
                // Request the update.
                try {
                    val installType = when {
                        appUpdateInfo.isUpdateTypeAllowed(AppUpdateType.FLEXIBLE) -> AppUpdateType.FLEXIBLE
                        appUpdateInfo.isUpdateTypeAllowed(AppUpdateType.IMMEDIATE) -> AppUpdateType.IMMEDIATE
                        else -> null
                    }
                    if (installType == AppUpdateType.FLEXIBLE) appUpdateManager.registerListener(appUpdatedListener)

                    appUpdateManager.startUpdateFlowForResult(
                            appUpdateInfo,
                            installType!!,
                            this,
                            APP_UPDATE_REQUEST_CODE)
                } catch (e: IntentSender.SendIntentException) {
                    e.printStackTrace()
                }
            }
        }
    }

    fun setupDrawer(toolbar: Toolbar){

        val headerResult = AccountHeaderBuilder()
                .withActivity(this as Activity)
                .withHeaderBackground(R.color.blue)
                .withSelectionListEnabledForSingleProfile(false)
                .addProfiles(
                    ProfileDrawerItem()
                            .withName("Ivoxis")
                            .withIcon(getResources().getDrawable(R.drawable.ethereum_logo))
                )
                .build()

        var item1 = PrimaryDrawerItem()
                    .withIdentifier(1)
                    .withName(R.string.drawer_item_home)
                    .withSelectedColor(getResources().getColor(R.color.white))

        //var item2 = PrimaryDrawerItem().withIdentifier(2).withName(R.string.drawer_item_buy)

        var item3 = PrimaryDrawerItem()
                    .withIdentifier(3)
                    .withName(R.string.drawer_item_tokens)

        var item4 = PrimaryDrawerItem()
                    .withIdentifier(4)
                    .withName(R.string.drawer_item_ether)

        var item5 = PrimaryDrawerItem()
                    .withIdentifier(5)
                    .withName(R.string.drawer_item_transfer)

        var item6 = PrimaryDrawerItem()
                    .withIdentifier(6)
                    .withName(R.string.drawer_item_data)

        var item7 = PrimaryDrawerItem()
                    .withIdentifier(7)
                    .withName(R.string.drawer_item_info)


        drawer = DrawerBuilder()
                .withActivity(this as Activity)
                .withAccountHeader(headerResult)
                .withToolbar(toolbar)
                .withSelectedItem(-1)
                .addDrawerItems(
                        item1,
                        DividerDrawerItem(),
                        //item2,
                        //DividerDrawerItem(),
                        item3,
                        DividerDrawerItem(),
                        item4,
                        DividerDrawerItem(),
                        item5,
                        DividerDrawerItem(),
                        item6,
                        DividerDrawerItem(),
                        item7
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

                        }  else if(drawerItem!!.identifier == 4.toLong()){

                            replaceFragment(EtherFragment.newInstance())

                        } else if(drawerItem!!.identifier == 5.toLong()){

                            replaceFragment(TransactionFragment.newInstance())

                        } else if(drawerItem!!.identifier == 6.toLong()){

                            replaceFragment(UserUpdateFragment.newInstance())

                        } else if(drawerItem!!.identifier == 7.toLong()){

                            replaceFragment(InfoFragment.newInstance())

                        }

                        //drawer?.setSelection(drawerItem)
                        drawer?.closeDrawer()
                        return true
                    }
                })
                .build()

        drawer!!.getActionBarDrawerToggle().drawerArrowDrawable.color = getResources().getColor(R.color.white)
    }

    override fun onResume() {
        super.onResume()
        appUpdateManager
                .appUpdateInfo
                .addOnSuccessListener { appUpdateInfo ->

                    // If the update is downloaded but not installed,
                    // notify the user to complete the update.
                    if (appUpdateInfo.installStatus() == InstallStatus.DOWNLOADED) {
                        popupSnackbarForCompleteUpdate()
                    }

                    //Check if Immediate update is required
                    try {
                        if (appUpdateInfo.updateAvailability() == UpdateAvailability.DEVELOPER_TRIGGERED_UPDATE_IN_PROGRESS) {
                            // If an in-app update is already running, resume the update.
                            appUpdateManager.startUpdateFlowForResult(
                                    appUpdateInfo,
                                    AppUpdateType.IMMEDIATE,
                                    this,
                                    APP_UPDATE_REQUEST_CODE)
                        }
                    } catch (e: IntentSender.SendIntentException) {
                        e.printStackTrace()
                    }
                }
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

        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == APP_UPDATE_REQUEST_CODE) {
            if (resultCode != Activity.RESULT_OK) {
                Toast.makeText(this,
                        getText(R.string.update_app_error),
                        Toast.LENGTH_SHORT)
                        .show()
            }
        }

        for (fragment in supportFragmentManager.fragments) {
            fragment.onActivityResult(requestCode, resultCode, data)
        }
    }

    private fun popupSnackbarForCompleteUpdate() {
        val snackbar = Snackbar.make(
                findViewById(R.id.main_fragment_container),
                getText(R.string.update_app_downloaded),
                Snackbar.LENGTH_INDEFINITE)
        snackbar.setAction(getText(R.string.update_app_restart)) { appUpdateManager.completeUpdate() }
        snackbar.setActionTextColor(ContextCompat.getColor(this, R.color.accent))
        snackbar.show()
    }


    override fun inject(appComponent: ApplicationComponent) {
        appComponent.inject(this)
    }
}

