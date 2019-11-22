package com.myetherwallet.mewconnect.feature.register.fragment.password

import android.os.Bundle
import android.support.v7.widget.Toolbar
import com.myetherwallet.mewconnect.R
import com.myetherwallet.mewconnect.core.extenstion.getString

private const val EXTRA_MNEMONIC = "mnemonic"
private const val EXTRA_PRIVATE_KEY = "private_key"

class PickPasswordFragment : BasePickPasswordFragment(), Toolbar.OnMenuItemClickListener {

    companion object {
        fun newInstance(mnemonic: String? = null, privateKey: String? = null): PickPasswordFragment {
            val fragment = PickPasswordFragment()
            val arguments = Bundle()
            mnemonic?.let {

                arguments.putString(EXTRA_MNEMONIC, mnemonic)

            }

            privateKey?.let{
                arguments.putString(EXTRA_PRIVATE_KEY, privateKey)
            }

            fragment.arguments = arguments
            return fragment
        }
    }

    override fun getTitle() = R.string.pick_password_title

    override fun getDescription() = R.string.pick_password_description

    override fun onNextClick(isNextEnabled: Boolean, password: String) {
        if (isNextEnabled) {
            addFragment(PasswordAgainFragment.newInstance(password, getString(EXTRA_MNEMONIC), getString(EXTRA_PRIVATE_KEY)))
        }
    }
}