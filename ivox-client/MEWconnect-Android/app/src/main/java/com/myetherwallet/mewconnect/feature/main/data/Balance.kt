package com.myetherwallet.mewconnect.feature.main.data

import java.math.BigDecimal
import java.math.BigInteger

data class Balance(
        val balance: BigDecimal,    // The total amoount
        val decimals: BigDecimal, // The rate
        val symbol: String,
        val address: String,
        val name: String?,
        val website: String?,
        val email: String?
) {

    fun calculateBalance(): BigDecimal {
        return balance
    }
}
