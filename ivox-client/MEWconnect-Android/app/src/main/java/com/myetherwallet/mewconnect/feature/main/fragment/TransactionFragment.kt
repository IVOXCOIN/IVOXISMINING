package com.myetherwallet.mewconnect.feature.main.fragment

import android.os.Bundle
import android.support.v7.widget.Toolbar
import android.view.MenuItem
import android.view.View
import android.widget.Toast
import com.myetherwallet.mewconnect.BuildConfig
import com.myetherwallet.mewconnect.R
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

class TransactionFragment : BaseDiFragment(), Toolbar.OnMenuItemClickListener {

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

        tokens_toolbar.inflateMenu(R.menu.close)
        tokens_toolbar.setOnMenuItemClickListener(this)

        address = preferences.getCurrentWalletPreferences().getWalletAddress()

        load()

    }

    private fun load(){
        loadAllBalances()
    }

    private fun displayToast(message: String){

        this.activity?.runOnUiThread(java.lang.Runnable {
            Toast.makeText(this.activity!!.applicationContext, message, Toast.LENGTH_LONG).show()
        })
    }

    private fun loadAllBalances(){
        getBalances()
    }

    private fun getBalances(){
        val json = JSONObject()
        val formatedEthereumAddress = "0x" + address

        json.put("destination", formatedEthereumAddress)

        val mediaType = MediaType.parse("application/json; charset=utf-8")

        val formBody = RequestBody.create(mediaType, json.toString())

        val parsedUrl = HttpUrl.parse(BuildConfig.IVOX_API_TOKEN_END_POINT)

        var builtUrl = HttpUrl.Builder()
                .scheme(parsedUrl?.scheme())
                .host(parsedUrl?.host())
                .port(parsedUrl?.port()!!)
                .addPathSegment("api")
                .addPathSegment("balance")
                .addPathSegment("get")
                .build()

        val request = Request.Builder()
                .url(builtUrl)
                .post(formBody)
                .build()

        client.newCall(request).enqueue(object : Callback {
            override fun onFailure(cliall: Call, e: IOException) {
                onAllBalancesFail(e.message!!)
            }
            override fun onResponse(call: Call, response: Response) {

                try{
                    var responseData = response.body()?.string()

                    var json = JSONArray(responseData)

                    var balanceItems = mutableListOf<IvoxToken>()

                    (0..(json.length()-1)).forEach { i ->
                        var item = json.getJSONObject(i)

                        val total = BigDecimal(item.getString("total"))
                        val eth = BigDecimal(item.getString("eth"))

                        val rate = total / eth

                        balanceItems.add(IvoxToken(item.getString("date"),
                                                    eth.toString(),
                                                    rate.toString(),
                                                    item.getString("paypal")))
                    }

                    onAllBalancesSuccess(balanceItems)

                }catch (e: Exception) {
                    onAllBalancesFail(e.message!!)
                }
            }

        })
    }

    private fun onAllBalancesFail(error: String) {
        displayToast(error)
        balances = mutableListOf()
        collect()
    }

    private fun onAllBalancesSuccess(result: MutableList<IvoxToken>) {
        balances = result
        collect()
    }

    private fun collect() {
        this.activity?.runOnUiThread(java.lang.Runnable {

            val dates     = mutableListOf<String>()
            val amounts   = mutableListOf<String>()
            val paypalIds = mutableListOf<String>()

            for (balance in balances!!) {
                val date    = balance.date
                val amount  = balance.amount
                val rate    = balance.rate
                val paypal  = balance.paypal

                dates.add(date)
                amounts.add(amount + " @" + rate)
                paypalIds.add(paypal)
            }

            val tokensListAdapter = TokensListAdapter(this.activity!!,
                                                        dates,
                                                        amounts,
                                                        paypalIds,
                                                        R.mipmap.ic_launcher)

            tokens_list.adapter = tokensListAdapter
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