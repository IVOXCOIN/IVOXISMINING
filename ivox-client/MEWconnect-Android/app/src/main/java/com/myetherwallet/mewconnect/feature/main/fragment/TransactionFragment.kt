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
import kotlinx.android.synthetic.main.fragment_tokens.tokens_toolbar
import kotlinx.android.synthetic.main.fragment_transaction.*
import kotlinx.android.synthetic.main.fragment_wallet.*
import org.web3j.crypto.ECKeyPair
import java.util.regex.Pattern


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