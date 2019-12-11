package com.myetherwallet.mewconnect.core.persist.prefenreces

import android.content.SharedPreferences
import com.myetherwallet.mewconnect.content.data.BalanceMethod
import com.myetherwallet.mewconnect.content.data.Network
import com.myetherwallet.mewconnect.core.utils.crypto.KeystoreHelper
import java.util.*

/**
 * Created by BArtWell on 10.07.2018.
 */

private const val WALLET_MNEMONIC = "wallet_mnemonic"
private const val WALLET_IS_BACKED_UP = "wallet_is_backed_up"
private const val PRIVATE_KEY_IS_BACKED_UP = "private_key_is_backed_up"
private const val USER_IS_REGISTERED = "user_is_registered"
private const val USER_NAME = "user_name"
private const val USER_EMAIL = "user_email"
private const val USER_PHONE = "user_phone"
private const val USER_ADDRESS = "user_address"
private const val USER_COUNTRY = "user_country"
private const val USER_CREDIT_CARD = "user_credit_card"
private const val CURRENT_NETWORK = "current_network"
private const val BALANCE_METHOD = "balance_method"
private const val BACKUP_WARNING_TIME = "backup_warning_time"
private const val PRIVATE_KEY_BACKUP_WARNING_TIME = "private_key_backup_warning_time"
private const val INSTALL_TIME = "install_time"

class ApplicationPreferences(private val preferences: SharedPreferences) {

    private val keystoreHelper: KeystoreHelper = KeystoreHelper()

    fun getWalletMnemonic(): String {
        return keystoreHelper.decrypt(preferences.getString(WALLET_MNEMONIC, "")!!)
    }

    fun setWalletMnemonic(mnemonic: String) {
        preferences.edit().putString(WALLET_MNEMONIC, keystoreHelper.encrypt(mnemonic)).apply()
    }

    fun isBackedUp() = preferences.getBoolean(WALLET_IS_BACKED_UP, false)

    fun setBackedUp(isBackedUp: Boolean) {
        preferences.edit().putBoolean(WALLET_IS_BACKED_UP, isBackedUp).apply()
    }

    fun isPrivateKeyBackedUp() = preferences.getBoolean(PRIVATE_KEY_IS_BACKED_UP, false)

    fun setPrivateKeyBackedUp(isBackedUp: Boolean) {
        preferences.edit().putBoolean(PRIVATE_KEY_IS_BACKED_UP, isBackedUp).apply()
    }


    fun getCurrentNetwork(): Network {
        return Network.valueOf(preferences.getString(CURRENT_NETWORK, Network.MAIN.name)!!)
    }

    fun setCurrentNetwork(network: Network) {
        preferences.edit().putString(CURRENT_NETWORK, network.name).apply()
    }

    fun getBalanceMethod(): BalanceMethod {
        return BalanceMethod.valueOf(preferences.getString(BALANCE_METHOD, BalanceMethod.IVOX.name)!!)
    }

    fun setBalanceMethod(method: BalanceMethod) {
        preferences.edit().putString(BALANCE_METHOD, method.name).apply()
    }

    fun isRegistered() = preferences.getBoolean(USER_IS_REGISTERED, false)

    fun setRegistered(isRegistered: Boolean) {
        preferences.edit().putBoolean(USER_IS_REGISTERED, isRegistered).apply()
    }


    fun getUserName(): String {
        return preferences.getString(USER_NAME, "")!!
    }

    fun setUserName(name: String) {
        preferences.edit().putString(USER_NAME, name).apply()
    }

    fun getUserEmail(): String {
        return preferences.getString(USER_EMAIL, "")!!
    }

    fun setUserEmail(email: String) {
        preferences.edit().putString(USER_EMAIL, email).apply()
    }

    fun getUserPhone(): String {
        return preferences.getString(USER_PHONE, "")!!
    }

    fun setUserPhone(phone: String) {
        preferences.edit().putString(USER_PHONE, phone).apply()
    }

    fun getUserAddress(): String {
        return preferences.getString(USER_ADDRESS, "")!!
    }

    fun setUserAddress(address: String) {
        preferences.edit().putString(USER_ADDRESS, address).apply()
    }

    fun getUserCountry(): String {
        return preferences.getString(USER_COUNTRY, "")!!
    }

    fun setUserCountry(country: String) {
        preferences.edit().putString(USER_COUNTRY, country).apply()
    }

    fun getUserCreditCard(): String {
        return preferences.getString(USER_CREDIT_CARD, "")!!
    }

    fun setUserCreditCard(creditCard: String) {
        preferences.edit().putString(USER_CREDIT_CARD, creditCard).apply()
    }


    fun getBackupWarningTime(): Long = preferences.getLong(BACKUP_WARNING_TIME, 0L)

    fun setBackupWarningTime() {
        preferences.edit().putLong(BACKUP_WARNING_TIME, System.currentTimeMillis()).apply()
    }

    fun getPrivateKeyBackupWarningTime(): Long = preferences.getLong(PRIVATE_KEY_BACKUP_WARNING_TIME, 0L)

    fun setPrivateKeyBackupWarningTime() {
        preferences.edit().putLong(PRIVATE_KEY_BACKUP_WARNING_TIME, System.currentTimeMillis()).apply()
    }


    fun getInstallTime(): Date {
        var timestamp = preferences.getLong(INSTALL_TIME, 0L)
        if (timestamp == 0L) {
            timestamp = System.currentTimeMillis()
            setInstallTime(timestamp)
        }
        return Date(timestamp)
    }

    fun setInstallTime(timestamp: Long = System.currentTimeMillis()) {
        if (!preferences.contains(INSTALL_TIME)) {
            preferences.edit().putLong(INSTALL_TIME, timestamp).apply()
        }
    }

    fun removeWalletData() {
        preferences.edit()
                .remove(WALLET_MNEMONIC)
                .remove(WALLET_IS_BACKED_UP)
                .remove(PRIVATE_KEY_IS_BACKED_UP)
                .remove(PRIVATE_KEY_BACKUP_WARNING_TIME)
                .remove(BACKUP_WARNING_TIME)
                .remove(BALANCE_METHOD)
                .remove(USER_IS_REGISTERED)
                .remove(USER_NAME)
                .remove(USER_EMAIL)
                .remove(USER_PHONE)
                .remove(USER_ADDRESS)
                .remove(USER_COUNTRY)
                .remove(USER_CREDIT_CARD)
                .remove(CURRENT_NETWORK)
                .apply()
    }
}