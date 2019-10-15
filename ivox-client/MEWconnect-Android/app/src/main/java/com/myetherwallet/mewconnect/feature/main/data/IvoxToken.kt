package com.myetherwallet.mewconnect.feature.main.data

data class IvoxToken(
        val paypalId: String,
        val id: String,
        val wallet: String,
        val currency: String,
        val date: String,
        val source: String,
        val destination: String,
        val value: String,
        val purchase: String,
        val rate: String,
        val status: String
)
