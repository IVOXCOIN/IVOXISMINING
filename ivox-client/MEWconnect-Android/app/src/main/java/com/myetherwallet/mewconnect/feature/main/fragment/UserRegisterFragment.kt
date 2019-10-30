package com.myetherwallet.mewconnect.feature.main.fragment

import android.app.AlertDialog
import android.content.DialogInterface
import android.os.Bundle
import android.support.v4.view.ViewCompat
import android.support.v7.widget.Toolbar
import android.text.Editable
import android.text.InputType
import android.text.TextUtils
import android.text.TextWatcher
import android.text.method.HideReturnsTransformationMethod
import android.text.method.PasswordTransformationMethod
import android.util.Log
import android.util.Patterns
import android.view.MenuItem
import android.view.View
import android.widget.ArrayAdapter
import android.widget.EditText
import android.widget.Toast
import br.com.moip.validators.CreditCard
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
import java.util.*
import java.util.regex.Pattern.matches
import javax.inject.Inject
import kotlin.collections.ArrayList

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

    private var isCardMasked: Boolean = true

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        /*ViewCompat.setOnApplyWindowInsetsListener(container) { view, insets ->
            insets.replaceSystemWindowInsets(0, 0, 0, insets.systemWindowInsetBottom).apply {
                ViewCompat.onApplyWindowInsets(view, this)
            }
        }*/

        setupCountry()


        user_credit_card.addTextChangedListener(object : TextWatcher {
            override fun afterTextChanged(p0: Editable?) {
            }

            override fun beforeTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {
            }

            override fun onTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {
                view_button.isEnabled = p0?.length != 0
            }
        })


        view_button.setOnClickListener {
            isCardMasked = !isCardMasked

            if(isCardMasked){
                view_button.setText(activity!!.getText(R.string.update_register_user_view))
                user_credit_card.transformationMethod = PasswordTransformationMethod.getInstance()
            } else {
                view_button.setText(activity!!.getText(R.string.update_register_user_hide))
                user_credit_card.transformationMethod = HideReturnsTransformationMethod.getInstance()
            }


        }

        register_button.setOnClickListener {

            userName = user_name.text.toString()
            userEmail = user_email.text.toString()
            userPhone = user_phone.text.toString()
            userAddress = user_address.text.toString()
            userCountry = user_country.getSelectedItem().toString()
            userCreditCard = user_credit_card.text.toString()
            userWallet = "0x" + preferences.getCurrentWalletPreferences().getWalletAddress()

            if(checkName(userName)){
                if(checkPhone(userPhone)){
                    if(checkEmail(userEmail)){

                        if(checkCreditCard(userCreditCard)){

                            val editText = EditText(activity!!)

                            editText.inputType = InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_VARIATION_PASSWORD

                            val builder = AlertDialog.Builder(activity!!)

                            builder.setTitle(activity!!.getText(R.string.update_register_user_continue))

                            builder.setMessage(activity!!.getText(R.string.update_register_user_password_confirm))

                            builder.setView(editText)

                            builder.setPositiveButton("OK"){dialog, which ->
                                userPassword = editText.text.toString()
                                val privateKey = StorageCryptHelper.decrypt(preferences.getCurrentWalletPreferences().getWalletPrivateKey(), userPassword)

                                if (checkPrivateKey(privateKey)) {

                                    registerUser()

                                } else {
                                    displayToast(activity!!.getText(R.string.register_password_error).toString())
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

                        } else {
                            displayToast(activity!!.getText(R.string.register_card_error).toString())
                        }

                    } else {
                        displayToast(activity!!.getText(R.string.register_email_error).toString())

                    }
                } else {
                    displayToast(activity!!.getText(R.string.register_phone_error).toString())
                }


            } else {
                displayToast(activity!!.getText(R.string.register_name_error).toString())
            }


        }

    }


    private fun setupCountry(){
        val locales = Locale.getAvailableLocales()
        val countries = ArrayList<String>()
        for (locale in locales) {
            val country = locale.getDisplayCountry()
            if (country.trim({ it <= ' ' }).length > 0 &&
                    !countries.contains(country) &&
                    !country.matches(".*\\d.*".toRegex())) {
                countries.add(country)
            }
        }


        Collections.sort(countries)

        val countryAdapter = ArrayAdapter(activity, android.R.layout.simple_spinner_item, countries)

        countryAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)

        // Apply the adapter to the your spinner
        user_country.setAdapter(countryAdapter)

    }

    private fun checkName(name: String): Boolean{
        return name.length >= 3
    }

    private fun checkPhone(phone: String): Boolean {
        val isEmpty = TextUtils.isEmpty(phone)
        val isCorrectLength = phone.length==10
        val phoneMatches = android.util.Patterns.PHONE.matcher(phone).matches()

        return  !isEmpty && (isCorrectLength) && phoneMatches
    }


    private fun checkEmail(email: String): Boolean{
        val isEmpty = TextUtils.isEmpty(email)
        val matches = Patterns.EMAIL_ADDRESS.matcher(email).matches()

        return !isEmpty && matches
    }

    private fun checkCreditCard(creditCard: String): Boolean{
        return CreditCard(creditCard).isValid()
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

                        preferences.applicationPreferences.setUserName(userName)
                        preferences.applicationPreferences.setUserEmail(userEmail)
                        preferences.applicationPreferences.setUserPhone(userPhone)
                        preferences.applicationPreferences.setUserAddress(userAddress)
                        preferences.applicationPreferences.setUserCountry(userCountry)
                        preferences.applicationPreferences.setUserCreditCard(userCreditCard)

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