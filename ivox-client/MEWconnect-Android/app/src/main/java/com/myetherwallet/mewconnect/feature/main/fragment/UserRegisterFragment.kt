package com.myetherwallet.mewconnect.feature.main.fragment

import android.os.Bundle
import android.support.v7.widget.Toolbar
import android.util.Log
import android.view.MenuItem
import android.view.View
import android.widget.Toast
import com.myetherwallet.mewconnect.BuildConfig
import com.myetherwallet.mewconnect.R
import com.myetherwallet.mewconnect.core.di.ApplicationComponent
import com.myetherwallet.mewconnect.core.persist.prefenreces.PreferencesManager
import com.myetherwallet.mewconnect.core.ui.fragment.BaseDiFragment
import com.myetherwallet.mewconnect.core.utils.HexUtils
import com.myetherwallet.mewconnect.core.utils.crypto.StorageCryptHelper
import okhttp3.*
import kotlinx.android.synthetic.main.fragment_user_register.*
import org.json.JSONArray
import org.json.JSONObject
import org.web3j.crypto.ECKeyPair
import java.io.IOException
import javax.inject.Inject

class UserRegisterFragment : BaseDiFragment(), Toolbar.OnMenuItemClickListener {

    companion object {
        fun newInstance() = UserRegisterFragment()
    }

    @Inject
    lateinit var preferences: PreferencesManager

    private val client = OkHttpClient()

    private var userName: String = ""
    private var userEmail: String = ""
    private var userPhone: String = ""
    private var userAddress: String = ""
    private var userCountry: String = ""
    private var userCreditCard: String = ""
    private var userWallet: String = ""
    private var userPassword: String = ""

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)


        register_button.setOnClickListener {

            userName = user_name.text.toString()
            userEmail = user_email.text.toString()
            userPhone = user_phone.text.toString()
            userAddress = user_address.text.toString()
            userCountry = user_country.text.toString()
            userCreditCard = user_credit_card.text.toString()
            userWallet = preferences.getCurrentWalletPreferences().getWalletAddress()
            userPassword = user_password.text.toString()

            val privateKey = StorageCryptHelper.decrypt(preferences.getCurrentWalletPreferences().getWalletPrivateKey(), userPassword)
            if (checkPrivateKey(privateKey)) {

                registerUser()

            } else {
                displayToast(activity!!.getText(R.string.register_password_error).toString())

            }

        }

    }

    private fun registerUser(){

        val json = JSONObject()

        json.put("name", userName)
        json.put("email", userEmail)
        json.put("phone", userPhone)
        json.put("address", userAddress)
        json.put("country", userCountry)
        json.put("card", userCreditCard)
        json.put("wallet", userWallet)
        json.put("password", userPassword)

        val mediaType = MediaType.parse("application/json; charset=utf-8")

        val formBody = RequestBody.create(mediaType, json.toString())

        val parsedUrl = HttpUrl.parse(BuildConfig.IVOX_API_TOKEN_END_POINT)

        var builtUrl = HttpUrl.Builder()
                .scheme(parsedUrl?.scheme())
                .host(parsedUrl?.host())
                .port(parsedUrl?.port()!!)
                .addPathSegment("api")
                .addPathSegment("user")
                .addPathSegment("register")
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

                        preferences.applicationPreferences.setUserEmail(userEmail)
                        preferences.applicationPreferences.setRegistered(true)
                        openWallet()

                    } else if(response.code() == 400){
                        displayToast(activity!!.getText(R.string.register_user_error).toString())

                    } else if(response.code() == 500){
                        displayToast(activity!!.getText(R.string.register_server_error).toString())
                    }


                }catch (e: Exception) {
                    displayToast(e.message!!)
                }
            }

        })
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

    private fun goBack(){
        this.activity?.runOnUiThread(java.lang.Runnable {
            close()
        })
    }

    private fun openWallet(){

        this.activity?.runOnUiThread(java.lang.Runnable {
            replaceFragment(WalletFragment.newInstance())
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

    override fun layoutId() = R.layout.fragment_user_register
}