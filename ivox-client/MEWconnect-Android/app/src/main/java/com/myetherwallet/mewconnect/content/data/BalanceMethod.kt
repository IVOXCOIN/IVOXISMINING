package com.myetherwallet.mewconnect.content.data

import android.content.Context
import com.myetherwallet.mewconnect.R

/**
 * Created by BArtWell on 04.09.2018.
 */
enum class BalanceMethod(val fullName: Int, val shortName: Int) {

    IVOX(R.string.balance_method_ivox_full, R.string.balance_method_ivox_short),
    ETHER(R.string.balance_method_ether_full, R.string.balance_method_ether_short);
    //RINKEBY(R.string.wallet_network_rinkeby_full, R.string.wallet_network_rinkeby_short, R.string.wallet_network_rinkeby_currency, "rin", "m/44'/1'/0'/0", 4);

    companion object {

        fun getTitles(context: Context): Array<String> {
            val titles = mutableListOf<String>()
            for (value in values()) {
                titles.add(context.getString(value.fullName))
            }
            return titles.toTypedArray()
        }
    }
}
