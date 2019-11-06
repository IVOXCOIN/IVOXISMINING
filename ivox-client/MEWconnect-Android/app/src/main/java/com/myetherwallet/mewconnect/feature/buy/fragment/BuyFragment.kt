package com.myetherwallet.mewconnect.feature.buy.fragment

import android.os.Bundle
import android.support.v7.widget.Toolbar
import android.util.TypedValue
import android.view.View
import android.view.View.GONE
import android.view.View.VISIBLE
import android.widget.Toast
import com.myetherwallet.mewconnect.R
import com.myetherwallet.mewconnect.core.di.ApplicationComponent
import com.myetherwallet.mewconnect.core.extenstion.formatMoney
import com.myetherwallet.mewconnect.core.extenstion.toStringWithoutZeroes
import com.myetherwallet.mewconnect.core.extenstion.viewModel
import com.myetherwallet.mewconnect.core.persist.prefenreces.PreferencesManager
import com.myetherwallet.mewconnect.core.ui.fragment.BaseViewModelFragment
import com.myetherwallet.mewconnect.feature.buy.activity.BuyWebViewActivity
import com.myetherwallet.mewconnect.feature.buy.viewmodel.BuyViewModel
import kotlinx.android.synthetic.main.fragment_buy.*
import java.math.BigDecimal
import java.math.BigInteger
import java.math.RoundingMode
import javax.inject.Inject

import org.json.JSONObject
import org.json.JSONArray
import org.json.JSONException

import java.io.IOException

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.util.Log
import com.myetherwallet.mewconnect.core.utils.KeyboardUtils
import com.myetherwallet.mewconnect.feature.main.activity.MainActivity
import com.myetherwallet.mewconnect.feature.main.fragment.WalletFragment

//import com.paypal.android.sdk.payments.PayPalAuthorization
import com.paypal.android.sdk.payments.PayPalConfiguration
//import com.paypal.android.sdk.payments.PayPalFuturePaymentActivity
//import com.paypal.android.sdk.payments.PayPalItem
//import com.paypal.android.sdk.payments.PayPalOAuthScopes
import com.paypal.android.sdk.payments.PayPalPayment
//import com.paypal.android.sdk.payments.PayPalPaymentDetails
//import com.paypal.android.sdk.payments.PayPalProfileSharingActivity
import com.paypal.android.sdk.payments.PayPalService
import com.paypal.android.sdk.payments.PaymentActivity
import com.paypal.android.sdk.payments.PaymentConfirmation
//import com.paypal.android.sdk.payments.ShippingAddress

import android.os.Handler

import com.myetherwallet.mewconnect.BuildConfig
import kotlinx.android.synthetic.main.fragment_tokens.*
import okhttp3.*

/**
 * Created by BArtWell on 12.09.2018.
 */

const val CURRENCY_MXN = "MXN"
const val CURRENCY_IVOX = "IVOX"
private const val ETH_DECIMALS = 8
private val LIMIT_MIN = BigDecimal(500)
private val LIMIT_MAX = BigDecimal(1500000)
private const val EXTRA_STOCK_PRICE = "stock_price"
private const val MAX_ETHER_VALUE = "1000000"


class BuyFragment : BaseViewModelFragment() {

    companion object {

        private val TAG = "paymentExample"
        /**
         * - Set to PayPalConfiguration.ENVIRONMENT_PRODUCTION to move real money.

         * - Set to PayPalConfiguration.ENVIRONMENT_SANDBOX to use your test credentials
         * from https://developer.paypal.com

         * - Set to PayPalConfiguration.ENVIRONMENT_NO_NETWORK to kick the tires
         * without communicating to PayPal's servers.
         */
        private val CONFIG_ENVIRONMENT = PayPalConfiguration.ENVIRONMENT_PRODUCTION

        // note that these credentials will differ between live & sandbox environments.
        private val CONFIG_CLIENT_ID = "AT9bbsd8BR0a3fJoasIcSjAVo0av2HCRbZYRYEoJoy97khQWV3vKa-txCP3FE4zq-NexrxtinZmZBOKh"

        private val REQUEST_CODE_PAYMENT = 1
        private val REQUEST_CODE_FUTURE_PAYMENT = 2
        private val REQUEST_CODE_PROFILE_SHARING = 3

        private val config = PayPalConfiguration()
                .environment(CONFIG_ENVIRONMENT)
                .clientId(CONFIG_CLIENT_ID)
                .merchantName("IVOX")
                .merchantPrivacyPolicyUri(Uri.parse("http://ivoxis.net/POLITICA_DE_PRIVACIDAD.pdf"))
                .merchantUserAgreementUri(Uri.parse("http://ivoxis.net/TERMINOS_Y_CONDICIONES_DE_IVOX.pdf"))

        fun newInstance(stockPrice: BigDecimal): BuyFragment {
            val fragment = BuyFragment()
            val arguments = Bundle()
            arguments.putSerializable(EXTRA_STOCK_PRICE, stockPrice)
            fragment.arguments = arguments
            return fragment
        }
    }

    @Inject
    lateinit var preferences: PreferencesManager
    private lateinit var viewModel: BuyViewModel

    private var textSizeMin = 0f
    private var textSizeMax = 0f
    private var isInUsd = false
    private var price = BigDecimal.ZERO
    private var gasPrice = BigDecimal.ZERO

    private var walletBalance: BigDecimal? = null


    private val client = OkHttpClient()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        viewModel = viewModel(viewModelFactory)

        textSizeMin = resources.getDimension(R.dimen.text_size_fixed_20sp)
        textSizeMax = resources.getDimension(R.dimen.text_size_fixed_48sp)

        (activity as MainActivity).setupDrawer(drawer_toolbar)

        /*buy_toolbar.setNavigationIcon(R.drawable.ic_action_close)
        buy_toolbar.setNavigationOnClickListener(View.OnClickListener { close() })
        buy_toolbar.setTitle(R.string.buy_title)
        buy_toolbar.inflateMenu(R.menu.buy)*/

        /*
        buy_toolbar.setOnMenuItemClickListener(Toolbar.OnMenuItemClickListener {
            if (it.itemId == R.id.buy_history) {
                addFragment(HistoryFragment.newInstance())
                true
            } else {
                false
            }
        })
        */

        //arguments!!.getSerializable(EXTRA_STOCK_PRICE) as BigDecimal

        buy_button_1.setOnClickListener { addDigit(1) }
        buy_button_2.setOnClickListener { addDigit(2) }
        buy_button_3.setOnClickListener { addDigit(3) }
        buy_button_4.setOnClickListener { addDigit(4) }
        buy_button_5.setOnClickListener { addDigit(5) }
        buy_button_6.setOnClickListener { addDigit(6) }
        buy_button_7.setOnClickListener { addDigit(7) }
        buy_button_8.setOnClickListener { addDigit(8) }
        buy_button_9.setOnClickListener { addDigit(9) }
        buy_button_point.setOnClickListener { addPoint() }
        buy_button_0.setOnClickListener { addDigit(0) }
        buy_button_delete.setOnClickListener { delete() }

        buy_button_delete.setOnLongClickListener {
            populateMainValue(BigDecimal.ZERO)
            true
        }

        /*buy_toggle_currency.setOnClickListener {
            isInUsd = !isInUsd
            val tmp = buy_sum_1.text
            setRawText(buy_sum_2.text.toString())
            buy_sum_2.text = tmp
            populateSecondValue()
        }*/

        buy_button.setOnClickListener {
            buy_loading.visibility = VISIBLE
            /*viewModel.load(BigDecimal(getCurrentValue()),
                    if (isInUsd) CURRENCY_MXN else CURRENCY_ETH,
                    preferences.getCurrentWalletPreferences().getWalletAddress(),
                    preferences.applicationPreferences.getInstallTime(),
                    {
                        startActivity(BuyWebViewActivity.createIntent(requireContext(), it.url, it.getEncodedPostData()))
                        buy_loading.visibility = GONE
                    },
                    {
                        Toast.makeText(context, R.string.buy_loading_error, Toast.LENGTH_LONG).show()
                    })
            */

            var currentValue = ""
            var ethereumValue = ""

            val text = getCurrentValue()

            if (isInUsd) {
                currentValue = BigDecimal(text).divide(price, ETH_DECIMALS, RoundingMode.HALF_UP).formatMoney(ETH_DECIMALS)
            } else {
                currentValue = BigDecimal(text).multiply(price).formatMoney(ETH_DECIMALS)
            }

            var decValue = BigDecimal(currentValue)

            if(isInUsd){
                ethereumValue = decValue.toString()
                currentValue = text
            } else {
                ethereumValue = decValue.divide(price, ETH_DECIMALS, RoundingMode.HALF_UP).formatMoney(ETH_DECIMALS)

            }

            if(walletBalance!! + BigDecimal(ethereumValue) <= BigDecimal(MAX_ETHER_VALUE)){
                val ethereumToBuy = getEthereumToBuy(PayPalPayment.PAYMENT_INTENT_SALE,
                        currentValue,
                        ethereumValue)

                val intent = Intent(this.activity, PaymentActivity::class.java)

                // send the same configuration for restart resiliency
                intent.putExtra(PayPalService.EXTRA_PAYPAL_CONFIGURATION, config)

                intent.putExtra(PaymentActivity.EXTRA_PAYMENT, ethereumToBuy)

                this.activity?.startActivityForResult(intent, REQUEST_CODE_PAYMENT)

                buy_loading.visibility = GONE

            } else {
                displayToast(activity!!.getText(R.string.buy_exceeded_limit).toString())

                buy_loading.visibility = GONE

                goBack()
            }

        }

        populateMainValue(BigDecimal.ZERO)


        disableButtons()

        getTicker()

        val intent = Intent(this.activity, PayPalService::class.java)
        intent.putExtra(PayPalService.EXTRA_PAYPAL_CONFIGURATION, config)
        this.activity?.startService(intent)

        //displayToast(this.activity!!.resources!!.displayMetrics!!.density.toString())
        

    }

    private fun getBalance(){

        val json = JSONObject()

        val network = preferences.applicationPreferences.getCurrentNetwork()

        val formatedEthereumAddress = "0x" + preferences.getCurrentWalletPreferences().getWalletAddress()

        json.put("account", formatedEthereumAddress)

        json.put("method", context!!.getString(preferences.applicationPreferences.getBalanceMethod().shortName))

        val mediaType = MediaType.parse("application/json; charset=utf-8")

        val formBody = RequestBody.create(mediaType, json.toString())

        val parsedUrl = HttpUrl.parse(BuildConfig.IVOX_API_TOKEN_END_POINT)

        var builtUrl = HttpUrl.Builder()
                .scheme(parsedUrl?.scheme())
                .host(parsedUrl?.host())
                .port(parsedUrl?.port()!!)
                .addPathSegment("ethereum")
                .addPathSegment("balance")
                .build()

        val request = Request.Builder()
                .url(builtUrl)
                .post(formBody)
                .build()

        client.newCall(request).enqueue(object : Callback {
            override fun onFailure(cliall: Call, e: IOException) {
                onWalletBalanceFail(e.message!!)
            }
            override fun onResponse(call: Call, response: Response) {

                try{
                    var responseData = response.body()?.string()

                    var json = JSONArray(responseData)

                    val response = json.getJSONObject(0)

                    val balanceString = response.getString("BALANCE")

                    val balance = BigDecimal(balanceString)

                    onWalletBalanceSuccess(balance)

                }catch (e: Exception) {
                    onWalletBalanceFail(e.message!!)
                }
            }

        })
    }

    private fun onWalletBalanceFail(error: String) {
        displayToast(error)
        walletBalance = BigDecimal.ZERO
    }

    private fun onWalletBalanceSuccess(result: BigDecimal) {
        walletBalance = result

        enableButtons()
    }

    private fun getEthereumToBuy(paymentIntent: String,
                                 paymentPrice: String,
                                 paymentEthereum: String): PayPalPayment {

        val method = context!!.getString(preferences.applicationPreferences.getBalanceMethod().shortName)

        val paymentTotal = BigDecimal(paymentPrice) + gasPrice

        val payment = PayPalPayment(    paymentTotal,
                                        "MXN",
                                        paymentEthereum + " " + method,
                                        paymentIntent   )

        val customObject = JSONObject()

        val network = preferences.applicationPreferences.getCurrentNetwork()

        val formatedEthereumAddress = "0x" + preferences.getCurrentWalletPreferences().getWalletAddress()

        customObject.put("method", method)
        customObject.put("source", formatedEthereumAddress)
        customObject.put("destination", formatedEthereumAddress)
        customObject.put("ether", paymentEthereum)
        customObject.put("currency", "MXN")
        customObject.put("amount", paymentTotal.toString())

        payment.custom(customObject.toString())

        return payment
    }

    private fun setGasPrice(newPrice: String){
        gasPrice = BigDecimal(newPrice)
    }

    private fun setPrice(newPrice: String){

        price = BigDecimal(newPrice)

    }

    private fun enableButtons(){
        this.activity?.runOnUiThread(java.lang.Runnable {
            buy_button_1.isEnabled = true
            buy_button_2.isEnabled = true
            buy_button_3.isEnabled = true
            buy_button_4.isEnabled = true
            buy_button_5.isEnabled = true
            buy_button_6.isEnabled = true
            buy_button_7.isEnabled = true
            buy_button_8.isEnabled = true
            buy_button_9.isEnabled = true
            buy_button_0.isEnabled = true

            val method = context!!.getString(preferences.applicationPreferences.getBalanceMethod().shortName)

            buy_button_point.isEnabled = method == "ETHER"

            buy_button_delete.isEnabled = true
            //buy_toggle_currency.isEnabled = true
        })
    }


    private fun disableButtons(){
        this.activity?.runOnUiThread(java.lang.Runnable {
            buy_button_1.isEnabled = false
            buy_button_2.isEnabled = false
            buy_button_3.isEnabled = false
            buy_button_4.isEnabled = false
            buy_button_5.isEnabled = false
            buy_button_6.isEnabled = false
            buy_button_7.isEnabled = false
            buy_button_8.isEnabled = false
            buy_button_9.isEnabled = false
            buy_button_0.isEnabled = false
            buy_button_point.isEnabled = false

            buy_button_delete.isEnabled = false
            //buy_toggle_currency.isEnabled = false
        })
    }

    private fun getTicker(){
        val method = context!!.getString(preferences.applicationPreferences.getBalanceMethod().shortName)

        val json = JSONObject()

        json.put("method", method)
        json.put("tag", CURRENCY_MXN)

        val mediaType = MediaType.parse("application/json; charset=utf-8")

        val formBody = RequestBody.create(mediaType, json.toString())

        val parsedUrl = HttpUrl.parse(BuildConfig.IVOX_API_TOKEN_END_POINT)

        var builtUrl = HttpUrl.Builder()
                                .scheme(parsedUrl?.scheme())
                                .host(parsedUrl?.host())
                                .port(parsedUrl?.port()!!)
                                .addPathSegment("api")
                                .addPathSegment("currency")
                                .addPathSegment("get")
                                .build()

        val request = Request.Builder()
                                .url(builtUrl)
                                .post(formBody)
                                .build()

        client.newCall(request).enqueue(object : Callback {
            override fun onFailure(cliall: Call, e: IOException) {
                displayToast("An error occurred")
                goBack()
            }
            override fun onResponse(call: Call, response: Response) {

                try{
                    var responseData = response.body()?.string()

                    var json = JSONArray(responseData)

                    val response = json.getJSONObject(0)

                    setPrice(response.getString("rate"))
                    getGas()

                }catch (e: Exception) {
                    displayToast("An error occurred")
                    goBack()
                }


            }

        })
    }

    private fun getGas(){
        val parsedUrl = HttpUrl.parse(BuildConfig.IVOX_API_TOKEN_END_POINT)

        var builtUrl = HttpUrl.Builder()
                                .scheme(parsedUrl?.scheme())
                                .host(parsedUrl?.host())
                                .port(parsedUrl?.port()!!)
                                .addPathSegment("api")
                                .addPathSegment("gas")
                                .addPathSegment("get")
                                .build()

        val request = Request.Builder()
                                .url(builtUrl)
                                .get()
                                .build()

        client.newCall(request).enqueue(object : Callback {
            override fun onFailure(cliall: Call, e: IOException) {
                displayToast("An error occurred")
                goBack()
            }
            override fun onResponse(call: Call, response: Response) {

                try{
                    var responseData = response.body()?.string()

                    var json = JSONArray(responseData)

                    val response = json.getJSONObject(0)

                    setGasPrice(response.getString("price"))

                    getBalance()

                }catch (e: Exception) {
                    displayToast("An error occurred")
                    goBack()
                }


            }

        })
    }

    private fun goBack(){
        this.activity?.runOnUiThread(java.lang.Runnable {
            close()
        })
    }

    private fun displayToast(message: String){

        this.activity?.runOnUiThread(java.lang.Runnable {
            Toast.makeText(context, message, Toast.LENGTH_LONG).show()
        })
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == REQUEST_CODE_PAYMENT) {
            if (resultCode == Activity.RESULT_OK) {
                val confirm = data?.getParcelableExtra<PaymentConfirmation>(PaymentActivity.EXTRA_RESULT_CONFIRMATION)
                if (confirm != null) {
                    try {
                        Log.i(TAG, confirm.toJSONObject().toString(4))
                        Log.i(TAG, confirm.payment.toJSONObject().toString(4))

                        Log.i(TAG, confirm.toJSONObject().getJSONObject("response").getString("id"))

                        var handler = Handler()
                        handler.post(java.lang.Runnable {
                            displayToast(activity!!.getText(R.string.transfer_complete).toString())
                            close()
                        })

                        /*
                        val formBody = FormBody.Builder()
                                .add("id", confirm.toJSONObject().getJSONObject("response").getString("id"))
                                .add("address", preferences.getCurrentWalletPreferences().getWalletAddress())
                                .build()

                        val request = Request.Builder()
                                .url("http://192.168.0.2:3000/ethereum/receive")
                                .post(formBody)
                                .build()

                        client.newCall(request).enqueue(object : Callback {
                            override fun onFailure(cliall: Call, e: IOException) {
                                // TODO display error toast here

                                // in this case the customer must get in touch
                                // with us with its PayPal transaction ID
                                // so we can validate
                                goBack()

                            }
                            override fun onResponse(call: Call, response: Response) {
                                var responseData = response.body()?.string()

                                goBack()
                            }

                        })
                        */

                    } catch (e: JSONException) {
                        Log.e(TAG, "an extremely unlikely failure occurred: ", e)
                    }

                }
            } else if (resultCode == Activity.RESULT_CANCELED) {
                Log.i(TAG, "The user canceled.")
            } else if (resultCode == PaymentActivity.RESULT_EXTRAS_INVALID) {
                Log.i(TAG, "An invalid Payment or PayPalConfiguration was submitted. Please see the docs.")
            }
        }
    }

    private fun populateMainValue(value: BigDecimal) {
        if (isInUsd) {
            setRawText(value.formatMoney(2))
        } else {
            setRawText(value.toStringWithoutZeroes())
        }
        populateSecondValue()
    }

    private fun populateSecondValue() {
        val text = getCurrentValue()
        if (isInUsd) {
            buy_sum_2.text = BigDecimal(text).divide(price, ETH_DECIMALS, RoundingMode.HALF_UP).formatMoney(ETH_DECIMALS)
        } else {
            buy_sum_2.text = BigDecimal(text).multiply(price).formatMoney(ETH_DECIMALS)
        }
        populateCurrency()
    }

    private fun getCurrentValue() = buy_sum_1.text.toString()

    private fun populateCurrency() {

        val method = context!!.getString(preferences.applicationPreferences.getBalanceMethod().shortName)

        if (isInUsd) {
            buy_currency_1.text = CURRENCY_MXN
            buy_symbol_1.text = "$"
            buy_currency_2.text = method
            buy_symbol_2.text = ""
        } else {
            buy_currency_1.text = method
            buy_symbol_1.text = ""
            buy_currency_2.text = ""
            buy_symbol_2.text = "$"
        }
        setupBuyButton()
    }

    private fun setupBuyButton() {
        var currentValue = BigDecimal(getCurrentValue())
        if (!isInUsd) {
            currentValue = currentValue.multiply(price)
        }

        val method = context!!.getString(preferences.applicationPreferences.getBalanceMethod().shortName)

        if (currentValue < LIMIT_MIN && method == "IVOX") {
            buy_button.setText(R.string.buy_minimum_warning)
            buy_button.isEnabled = false
        } else if(currentValue > BigDecimal(0)){
            buy_button.setText(R.string.buy_button)
            buy_button.isEnabled = true
        }
    }

    private fun delete() {
        var text = getCurrentValue()
        val length = text.length
        text = text.substring(0, length - 1)
        if (text.isEmpty()) {
            populateMainValue(BigDecimal.ZERO)
        } else {
            setRawText(text)
            populateSecondValue()
        }
    }

    private fun addPoint() {
        val text = getCurrentValue()
        val value = BigDecimal(text)
        if (value < LIMIT_MAX) {
            if (value.unscaledValue() == BigInteger.ZERO) {
                setRawText("0.")
                populateSecondValue()
            } else if (!text.contains(".")) {
                setRawText("$text.")
            }
        }
    }

    private fun setRawText(value: String) {
        buy_sum_1.text = value
        val delta = (textSizeMax - textSizeMin) * (value.length / 18f)
        val textSize = textSizeMax - delta
        buy_symbol_1.setTextSize(TypedValue.COMPLEX_UNIT_PX, textSize)
        buy_sum_1.setTextSize(TypedValue.COMPLEX_UNIT_PX, textSize)
    }

    private fun addDigit(digit: Int) {
        var text = getCurrentValue()
        if (BigDecimal(text).unscaledValue() == BigInteger.ZERO && !text.contains(".")) {
            text = ""
        }
        val length = text.length
        val newValue = text + digit
        if (isInUsd) {
            if (length >= 3 && text.substring(length - 3, length - 2) == ".") { // If already has 2 decimals
                return
            }
            if (BigDecimal(newValue) > LIMIT_MAX) {
                populateMainValue(LIMIT_MAX)
                return
            }
        } else {
            if (length >= ETH_DECIMALS + 1 && text.substring(length - ETH_DECIMALS - 1, length - ETH_DECIMALS) == ".") { // If already has 18 decimals
                return
            }
            val limit = LIMIT_MAX.divide(price, ETH_DECIMALS, RoundingMode.HALF_UP)
            if (BigDecimal(newValue) > limit) {
                populateMainValue(limit)
                return
            }
        }
        setRawText(newValue)
        populateSecondValue()
    }

    override fun inject(appComponent: ApplicationComponent) {
        appComponent.inject(this)
    }

    override fun layoutId() = R.layout.fragment_buy
}