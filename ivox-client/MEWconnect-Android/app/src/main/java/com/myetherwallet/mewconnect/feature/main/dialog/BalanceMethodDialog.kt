package com.myetherwallet.mewconnect.feature.main.dialog

import android.app.Dialog
import android.os.Bundle
import android.support.v7.app.AlertDialog
import com.myetherwallet.mewconnect.R
import com.myetherwallet.mewconnect.content.data.BalanceMethod
import com.myetherwallet.mewconnect.core.ui.dialog.BaseDialogFragment

private const val TAG = "BalanceMethodDialog"

class BalanceMethodDialog : BaseDialogFragment() {

    companion object {

        fun newInstance() = BalanceMethodDialog()
    }

    var listener: ((method: BalanceMethod) -> Unit)? = null

    override fun onCreateDialog(savedInstanceState: Bundle?): Dialog =
            AlertDialog.Builder(requireContext())
                    .setTitle(R.string.balance_method_title)
                    .setItems(BalanceMethod.getTitles(requireContext())) { _, i -> listener?.invoke(BalanceMethod.values()[i]) }
                    .create()

    override fun getFragmentTag() = TAG
}