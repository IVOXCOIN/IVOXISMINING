package com.myetherwallet.mewconnect.feature.main.fragment

import android.app.AlertDialog
import android.content.DialogInterface
import android.os.Bundle
import android.support.v7.widget.Toolbar
import android.text.InputType
import android.view.MenuItem
import android.view.View
import android.widget.EditText
import android.widget.Toast
import com.myetherwallet.mewconnect.BuildConfig
import com.myetherwallet.mewconnect.R
import com.myetherwallet.mewconnect.core.di.ApplicationComponent
import com.myetherwallet.mewconnect.core.persist.prefenreces.PreferencesManager
import com.myetherwallet.mewconnect.core.ui.fragment.BaseDiFragment
import com.myetherwallet.mewconnect.core.utils.ApplicationUtils
import com.myetherwallet.mewconnect.core.utils.LaunchUtils
import com.myetherwallet.mewconnect.core.utils.crypto.StorageCryptHelper
import com.myetherwallet.mewconnect.feature.main.activity.MainActivity
import com.myetherwallet.mewconnect.feature.main.dialog.ResetWalletDialog
import okhttp3.*
import kotlinx.android.synthetic.main.fragment_info.*
import org.json.JSONObject
import org.web3j.crypto.ECKeyPair
import java.io.IOException
import javax.inject.Inject

/**
 * Created by BArtWell on 15.08.2018.
 */
class InfoFragment : BaseDiFragment(), Toolbar.OnMenuItemClickListener {

    companion object {
        fun newInstance() = InfoFragment()
    }

    @Inject
    lateinit var preferences: PreferencesManager

    private val client = OkHttpClient()


    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        (activity as MainActivity).setupDrawer(info_toolbar)


        //info_toolbar.inflateMenu(R.menu.close)
        //info_toolbar.setOnMenuItemClickListener(this)

        info_contact.setOnClickListener { LaunchUtils.openMailApp(context, "support@myetherwallet.com") }
        info_user_agreement.setOnClickListener { LaunchUtils.openWebSite(context, "http://ivoxis.net/TERMINOS_Y_CONDICIONES_DE_IVOX.pdf") }
        info_privacy_and_terms.setOnClickListener { LaunchUtils.openWebSite(context, "http://ivoxis.net/POLITICA_DE_PRIVACIDAD.pdf") }
        info_site.setOnClickListener { LaunchUtils.openWebSite(context, "https://www.ivoxcoin.com") }

        info_version.text = getString(R.string.info_version, BuildConfig.VERSION_NAME, BuildConfig.VERSION_CODE)

        info_reset_wallet.setOnClickListener {
            val dialog = ResetWalletDialog.newInstance()
            dialog.listener = {
                removeUser()
            }
            dialog.show(childFragmentManager)
        }
    }

    private fun removeUser(){
        val editText = EditText(activity!!)

        editText.inputType = InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_VARIATION_PASSWORD

        val builder = AlertDialog.Builder(activity!!)

        builder.setTitle(activity!!.getText(R.string.reset_wallet_confirm_title))

        builder.setMessage(activity!!.getText(R.string.reset_wallet_confirm))

        builder.setView(editText)

        builder.setPositiveButton("OK"){dialog, which ->
            val password = editText.text.toString()
            val privateKey = StorageCryptHelper.decrypt(preferences.getCurrentWalletPreferences().getWalletPrivateKey(), password)

            if (checkPrivateKey(privateKey)) {

                val json = JSONObject()

                json.put("email", preferences.applicationPreferences.getUserEmail())
                json.put("wallet", preferences.getCurrentWalletPreferences().getWalletAddress())
                json.put("password", password)

                val mediaType = MediaType.parse("application/json; charset=utf-8")

                val formBody = RequestBody.create(mediaType, json.toString())

                val parsedUrl = HttpUrl.parse(BuildConfig.IVOX_API_TOKEN_END_POINT)

                var builtUrl = HttpUrl.Builder()
                        .scheme(parsedUrl?.scheme())
                        .host(parsedUrl?.host())
                        .port(parsedUrl?.port()!!)
                        .addPathSegment("api")
                        .addPathSegment("user")
                        .addPathSegment("delete")
                        .build()

                val request = Request.Builder()
                        .url(builtUrl)
                        .post(formBody)
                        .build()

                client.newCall(request).enqueue(object : Callback {
                    override fun onFailure(cliall: Call, e: IOException) {
                        displayToast(e.message!!)
                    }

                    override fun onResponse(call: Call, response: Response) {

                        try{
                            if(response.code() == 200){

                                destroyData()

                            } else if(response.code() == 401){
                                displayToast(activity!!.getText(R.string.reset_wallet_email_error).toString())

                            } else if(response.code() == 500){
                                displayToast(activity!!.getText(R.string.register_server_error).toString())
                            }


                        }catch (e: Exception) {
                            displayToast(e.message!!)
                        }
                    }

                })


            } else {
                displayToast(activity!!.getText(R.string.transfer_wrong_password).toString())
            }


        }

        builder.setNegativeButton("Cancelar", null)

        val dialog: AlertDialog = builder.create()

        dialog.setOnShowListener(DialogInterface.OnShowListener {
            dialog.getButton(AlertDialog.BUTTON_POSITIVE).setBackgroundColor(resources.getColor(R.color.blue))
            dialog.getButton(AlertDialog.BUTTON_POSITIVE).setTextColor(resources.getColor(R.color.white))

            dialog.getButton(AlertDialog.BUTTON_NEGATIVE).setBackgroundColor(resources.getColor(R.color.blue))
            dialog.getButton(AlertDialog.BUTTON_NEGATIVE).setTextColor(resources.getColor(R.color.white))
        })

        dialog.show()
    }

    private fun checkPrivateKey(privateKey: ByteArray?): Boolean {
        privateKey?.let {
            val ecKeyPair = ECKeyPair.create(it)
            if (ecKeyPair != null && ecKeyPair.publicKey != null) {
                return true
            }
        }
        return false
    }

    private fun destroyData(){
        this.activity?.runOnUiThread(java.lang.Runnable {
            ApplicationUtils.removeAllData(context, preferences)
            replaceFragment(IntroFragment.newInstance())
        })
    }

    private fun displayToast(message: String){

        this.activity?.runOnUiThread(java.lang.Runnable {
            Toast.makeText(this.activity!!.applicationContext, message, Toast.LENGTH_LONG).show()
        })
    }

    override fun onMenuItemClick(menuItem: MenuItem): Boolean {
        close()
        return true
    }

    override fun inject(appComponent: ApplicationComponent) {
        appComponent.inject(this)
    }

    override fun layoutId() = R.layout.fragment_info
}