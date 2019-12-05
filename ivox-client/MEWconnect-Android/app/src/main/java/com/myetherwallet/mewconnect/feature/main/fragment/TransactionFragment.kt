package com.myetherwallet.mewconnect.feature.main.fragment

import android.app.AlertDialog
import android.content.Context
import android.content.DialogInterface
import android.os.Bundle
import android.support.v7.widget.Toolbar
import android.view.MenuItem
import android.view.View
import android.widget.Toast
import com.myetherwallet.mewconnect.R
import com.myetherwallet.mewconnect.BuildConfig
import com.myetherwallet.mewconnect.core.di.ApplicationComponent
import com.myetherwallet.mewconnect.core.persist.prefenreces.PreferencesManager
import com.myetherwallet.mewconnect.core.ui.fragment.BaseDiFragment
import com.myetherwallet.mewconnect.feature.main.adapter.TokensListAdapter
import com.myetherwallet.mewconnect.feature.main.data.IvoxToken
import kotlinx.android.synthetic.main.fragment_tokens.*
import okhttp3.*
import org.json.JSONArray
import org.json.JSONObject
import java.io.IOException
import java.math.BigDecimal
import javax.inject.Inject
import android.view.ViewGroup
import android.view.LayoutInflater
import android.support.v4.view.PagerAdapter
import android.text.InputFilter
import android.text.InputType
import android.text.SpannableString
import android.text.Spanned
import android.text.util.Linkify
import android.util.Log
import android.widget.EditText
import com.myetherwallet.mewconnect.core.utils.HexUtils
import com.myetherwallet.mewconnect.core.utils.crypto.StorageCryptHelper
import com.myetherwallet.mewconnect.feature.main.activity.MainActivity
import com.myetherwallet.mewconnect.feature.main.data.MICE
import kotlinx.android.synthetic.main.fragment_info.*
//import kotlinx.android.synthetic.main.fragment_tokens.tokens_toolbar
import kotlinx.android.synthetic.main.fragment_transaction.*
import kotlinx.android.synthetic.main.fragment_wallet.*
import org.web3j.crypto.ECKeyPair
import java.util.regex.Pattern

import org.web3j.crypto.Credentials
import org.web3j.crypto.WalletUtils
import org.web3j.protocol.Web3j
import org.web3j.protocol.Web3jFactory
import org.web3j.protocol.core.methods.response.TransactionReceipt
import org.web3j.protocol.http.HttpService
import org.web3j.tx.ChainId
import org.web3j.tx.Contract.GAS_LIMIT
import org.web3j.tx.ManagedTransaction.GAS_PRICE
import org.web3j.tx.RawTransactionManager
import org.web3j.tx.Transfer
//import org.web3j.tx.gas.ContractGasProvider
//import org.web3j.tx.gas.DefaultGasProvider
import org.web3j.tx.response.NoOpProcessor
import org.web3j.utils.Convert
import org.web3j.utils.Numeric
import java.lang.NumberFormatException
import java.math.BigInteger

private const val CONTRACT_ADDRESS = "0x1c26C58d230B48A7e012F27D769703909309c75c"
private const val INFURA_URL = "https://mainnet.infura.io/v3/1febc18120a2467b9820ed83e95c0cfa"

class TransactionFragment : BaseDiFragment(), Toolbar.OnMenuItemClickListener {

    class InputFilterMaxDecimals(digitsBeforeZero:Int, digitsAfterZero:Int): InputFilter {

        private var mPattern: Pattern? = null

        init{
            mPattern=Pattern.compile("[0-9]{0," + (digitsBeforeZero-1) + "}+((\\.[0-9]{0," + (digitsAfterZero-1) + "})?)||(\\.)?")
        }

        override fun filter(source:CharSequence, start:Int, end:Int, dest: Spanned, dstart:Int, dend:Int): CharSequence? {
            var matcher=mPattern!!.matcher(dest)

            if(!matcher.matches()){
                return ""
            } else{
                return null
            }

        }
    }

    companion object {
        fun newInstance() = TransactionFragment()
    }

    @Inject
    lateinit var preferences: PreferencesManager

    private val client = OkHttpClient()

    private var address: String = ""
    private var balances: MutableList<IvoxToken>? = mutableListOf<IvoxToken>()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        (activity as MainActivity).setupDrawer(transaction_toolbar)

        //transaction_toolbar.inflateMenu(R.menu.close)
        //transaction_toolbar.setOnMenuItemClickListener(this)

        address = preferences.getCurrentWalletPreferences().getWalletAddress()

        confirm_transaction_cancel.setOnClickListener {
            replaceFragment(WalletFragment.newInstance())
        }


        confirm_transaction_wallet_address.setText("")
        confirm_transaction_amount.setText("0")

        confirm_transaction_amount.filters = arrayOf<InputFilter>(InputFilterMaxDecimals(5, 4))


        updateCheckBoxState(confirm_transaction_wallet_container, true)
        updateCheckBoxState(confirm_transaction_amount_container, true)
        updateOkButtonState()

        confirm_transaction_wallet_checkbox.setOnCheckedChangeListener{ buttonView, isChecked ->
            //confirm_transaction_wallet_checkbox.isChecked = !confirm_transaction_wallet_checkbox.isChecked
            //updateCheckBoxState(confirm_transaction_wallet_container, confirm_transaction_wallet_checkbox.isChecked)


            confirm_transaction_wallet_address.isEnabled = !isChecked

            updateOkButtonState()
        }

        confirm_transaction_amount_checkbox.setOnCheckedChangeListener{ buttonView, isChecked ->
            //confirm_transaction_amount_checkbox.isChecked = !confirm_transaction_amount_checkbox.isChecked
            //updateCheckBoxState(confirm_transaction_amount_container, confirm_transaction_amount_checkbox.isChecked)

            confirm_transaction_amount.isEnabled = !isChecked

            updateOkButtonState()
        }


        var s = SpannableString(activity!!.getText(R.string.transfer_ether_message))
        Linkify.addLinks(s, Linkify.ALL)

        val builder = AlertDialog.Builder(activity!!)

        builder.setTitle(activity!!.getText(R.string.transfer_info))

        builder.setMessage(s)

        builder.setPositiveButton("OK"){dialog, which ->
            val builder = AlertDialog.Builder(activity!!)

            builder.setTitle(activity!!.getText(R.string.transfer_info))

            builder.setMessage(activity!!.getText(R.string.transfer_usage_message))

            builder.setPositiveButton("OK"){dialog, which ->

            }

            val dialog: AlertDialog = builder.create()

            dialog.setOnShowListener(DialogInterface.OnShowListener {
                dialog.getButton(AlertDialog.BUTTON_POSITIVE).setBackgroundColor(resources.getColor(R.color.blue))
                dialog.getButton(AlertDialog.BUTTON_POSITIVE).setTextColor(resources.getColor(R.color.white))
            })

            dialog.show()
        }

        val dialog: AlertDialog = builder.create()

        dialog.setOnShowListener(DialogInterface.OnShowListener {
            dialog.getButton(AlertDialog.BUTTON_POSITIVE).setBackgroundColor(resources.getColor(R.color.blue))
            dialog.getButton(AlertDialog.BUTTON_POSITIVE).setTextColor(resources.getColor(R.color.white))
        })

        dialog.show()

        confirm_transaction_ok.setOnClickListener {

            var transaction_amount = 0.0

            try{

                transaction_amount = confirm_transaction_amount.text.toString().toDouble()

            } catch(e: NumberFormatException){
                transaction_amount = 0.0
            }

            if(transaction_amount == 0.0){

                displayToast(activity!!.getText(R.string.transfer_amount_error).toString())
            } else {


                val editText = EditText(activity!!)

                editText.inputType = InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_VARIATION_PASSWORD

                val builder = AlertDialog.Builder(activity!!)

                builder.setTitle(activity!!.getText(R.string.transfer_info))

                builder.setMessage(activity!!.getText(R.string.transfer_confirm_message))

                builder.setView(editText)

                builder.setPositiveButton("OK"){dialog, which ->
                    val password = editText.text.toString()
                    val privateKey = StorageCryptHelper.decrypt(preferences.getCurrentWalletPreferences().getWalletPrivateKey(), password)

                    var isDestinationWalletValid = false

                    if(Ethereum.isValidAddress(confirm_transaction_wallet_address.text.toString()))
                    {
                        isDestinationWalletValid = true
                    }
                    else if(Ethereum.isChecksumAddress(confirm_transaction_wallet_address.text.toString()))
                    {
                        isDestinationWalletValid = true
                    }

                    if(!isDestinationWalletValid){
                        displayToast(activity!!.getText(R.string.transfer_wallet_error).toString())
                    } else {
                        if (checkPrivateKey(privateKey)) {

                            val privateKeyString = HexUtils.bytesToStringLowercase(privateKey)

                            transferCoins(confirm_transaction_wallet_address.text.toString(),
                                            transaction_amount,
                                            privateKeyString,
                                            password)

                        } else {
                            displayToast(activity!!.getText(R.string.transfer_wrong_password).toString())
                        }

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

        }


    }

    private fun updateCheckBoxState(container: ViewGroup, isChecked: Boolean) {
        container.isEnabled = isChecked
    }

    private fun updateOkButtonState() {
        val isAllChecked = confirm_transaction_wallet_checkbox.isChecked && confirm_transaction_amount_checkbox.isChecked
        confirm_transaction_ok.isEnabled = isAllChecked
    }

    fun transferCoins (toAccount: String, coinAmount: Double, clientPrivateKey: String, password: String){


        // if testing, use https://ropsten.etherscan.io/address/[Your contract address]

        var web3 = Web3jFactory.build(HttpService(INFURA_URL))


        try{

            val privateKey = clientPrivateKey
            val key = BigInteger(privateKey,16)
            var ecKeyPair = ECKeyPair.create(key.toByteArray())
            var credentials = Credentials.create(ecKeyPair)


            var transactionReceiptProcessor = NoOpProcessor(web3)
            var transactionManager = RawTransactionManager(web3,
                                                            credentials,
                                                            ChainId.MAINNET,
                                                            transactionReceiptProcessor)


            // need to use the java wrapper filed generated before
            var mycontract = MICE.load(CONTRACT_ADDRESS, web3, transactionManager, GAS_PRICE, BigInteger("200000"))


            var value = Convert.toWei(coinAmount.toString(), Convert.Unit.ETHER).toBigInteger()
            var balance = mycontract.balanceOf(address).sendAsync().get()

            if(balance - value >= BigInteger("0")){
                try {

                    var mReceipt = mycontract.transfer(toAccount, value).sendAsync().get()

                    val sTransHash = mReceipt.getTransactionHash()


                    System.out.println("toAccount: " + toAccount + " coinAmount: " + coinAmount + " transactionhash: " + sTransHash)

                    // You can view the transaction record on https://etherscan.io/tx/[transaction hash]
                    // if testing , on https://ropsten.etherscan.io/tx/[transaction hash]

                    val transactionHash = "https://etherscan.io/tx/" + sTransHash
                    val email = preferences.applicationPreferences.getUserEmail()
                    val method = context!!.getString(preferences.applicationPreferences.getBalanceMethod().shortName)
                    val amount = -coinAmount

                    postTransaction(transactionHash,
                                    email,
                                    method,
                                    "0x" + address,
                                    toAccount,
                                    preferences.getWalletPreferences(preferences.applicationPreferences.getCurrentNetwork()).getWalletCurrency(),
                                    amount.toString(),
                                    "N/A",
                                    "0x" + address,
                                    password)

                } catch (e: Exception) {
                    System.out.println("Ethereum Exception " + e.message)
                    displayToast("Ethereum Exception " + e.message)
                    goHome()
                }
            } else {
                displayToast(activity!!.getText(R.string.transfer_insufficient_funds).toString())
                goHome()
            }



        }catch(e: IOException){
            System.out.println("Ethereum IOException " + e.message)

            displayToast("Ethereum IOException " + e.message)
            goHome()
        }
    }

    private fun postTransaction(transactionHash: String,
                                email: String,
                                method: String,
                                source: String,
                                destination: String,
                                currency: String,
                                value: String,
                                purchase: String,
                                wallet: String,
                                password: String){

        val json = JSONObject()

        json.put("id", transactionHash)
        json.put("email", email)
        json.put("method", method)
        json.put("source", source)
        json.put("destination", destination)
        json.put("currency", currency)
        json.put("value", value)
        json.put("purchase", purchase)
        json.put("wallet", wallet)
        json.put("password", password)

        val mediaType = MediaType.parse("application/json; charset=utf-8")

        val formBody = RequestBody.create(mediaType, json.toString())

        val parsedUrl = HttpUrl.parse(BuildConfig.IVOX_API_TOKEN_END_POINT)

        var builtUrl = HttpUrl.Builder()
                .scheme(parsedUrl?.scheme())
                .host(parsedUrl?.host())
                .port(parsedUrl?.port()!!)
                .addPathSegment("api")
                .addPathSegment("transaction")
                .addPathSegment("add")
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

                        displayToast(activity!!.getText(R.string.transfer_complete).toString())

                        goHome()

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

    private fun goHome(){
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

    override fun layoutId() = R.layout.fragment_transaction
}