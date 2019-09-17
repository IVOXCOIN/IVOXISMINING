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
import android.text.SpannableString
import android.text.Spanned
import android.text.util.Linkify
import android.widget.EditText
import com.myetherwallet.mewconnect.core.utils.HexUtils
import com.myetherwallet.mewconnect.core.utils.crypto.StorageCryptHelper
import com.myetherwallet.mewconnect.feature.main.data.MICE
import kotlinx.android.synthetic.main.fragment_tokens.tokens_toolbar
import kotlinx.android.synthetic.main.fragment_transaction.*
import kotlinx.android.synthetic.main.fragment_wallet.*
import org.web3j.crypto.ECKeyPair
import java.util.regex.Pattern

import org.web3j.crypto.Credentials
import org.web3j.crypto.WalletUtils
import org.web3j.protocol.Web3j
//import org.web3j.protocol.Web3jFactory
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

        transaction_toolbar.inflateMenu(R.menu.close)
        transaction_toolbar.setOnMenuItemClickListener(this)

        address = preferences.getCurrentWalletPreferences().getWalletAddress()

        transfer_amount.filters = arrayOf<InputFilter>(InputFilterMaxDecimals(5, 4))


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

        confirm_transfer_tokens.setOnClickListener {
            val editText = EditText(activity!!)
            val builder = AlertDialog.Builder(activity!!)

            builder.setTitle(activity!!.getText(R.string.transfer_info))

            builder.setMessage(activity!!.getText(R.string.transfer_confirm_message))

            builder.setView(editText)

            builder.setPositiveButton("OK"){dialog, which ->
                val password = editText.text.toString()
                val privateKey = StorageCryptHelper.decrypt(preferences.getCurrentWalletPreferences().getWalletPrivateKey(), password)
                if (checkPrivateKey(privateKey)) {

                    val privateKeyString = HexUtils.bytesToStringLowercase(privateKey)

                    displayToast(privateKeyString)

                } else {

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

    fun transferCoins (toAccount: String, coinAmount: Int, clientPrivateKey: String){


        // if testing, use https://ropsten.etherscan.io/address/[Your contract address]

        var web3 = Web3j.build(HttpService(INFURA_URL))


        try{

            var web3ClientVersion = web3.web3ClientVersion().send()
            var clientVersion = web3ClientVersion.getWeb3ClientVersion()
            System.out.println("clientVersion " + clientVersion)

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
            var mycontract = MICE.load(CONTRACT_ADDRESS, web3, transactionManager, GAS_PRICE, GAS_LIMIT)


            var _value = BigInteger.valueOf( (coinAmount * Math.pow(10.0, 8.0)).toLong() )


            try {

                var mReceipt = mycontract.transfer(toAccount, _value).sendAsync().get()

                val sTransHash = mReceipt.getTransactionHash()


                System.out.println("toAccount: " + toAccount + " coinAmount: " + coinAmount + " transactionhash: " + sTransHash)

                // You can view the transaction record on https://etherscan.io/tx/[transaction hash]
                // if testing , on https://ropsten.etherscan.io/tx/[transaction hash]
            } catch (e: Exception) {
                System.out.println("Ethereum Exception " + e.message)
                displayToast("Ethereum Exception " + e.message)

            }

        }catch(e: IOException){
            System.out.println("Ethereum IOException " + e.message)

            displayToast("Ethereum IOException " + e.message)
        }
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