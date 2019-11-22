package com.myetherwallet.mewconnect.feature.auth.fragment

import android.os.Bundle
import android.support.annotation.ColorRes
import android.support.annotation.StringRes
import android.support.v4.content.ContextCompat
import android.support.v7.widget.Toolbar
import android.view.MenuItem
import android.view.View
import android.view.inputmethod.EditorInfo
import com.myetherwallet.mewconnect.R
import com.myetherwallet.mewconnect.core.extenstion.getString
import com.myetherwallet.mewconnect.core.ui.callback.EmptyTextWatcher
import com.myetherwallet.mewconnect.core.ui.fragment.BaseFragment
import com.myetherwallet.mewconnect.core.utils.KeyboardStateObserver
import com.myetherwallet.mewconnect.core.utils.KeyboardUtils
import com.myetherwallet.mewconnect.feature.register.fragment.GeneratingFragment
import com.myetherwallet.mewconnect.feature.register.fragment.password.PickPasswordFragment

import kotlinx.android.synthetic.main.fragment_enter_private_key.*
import kotlinx.android.synthetic.main.fragment_enter_private_key.view.*
import org.web3j.crypto.Credentials
import org.web3j.crypto.ECKeyPair
import java.math.BigInteger

class BaseEnterPrivateKeyFragment : BaseFragment(), Toolbar.OnMenuItemClickListener {

    private lateinit var keyboardStateObserver: KeyboardStateObserver
    private var isNextEnabled: Boolean = false
        set(value) {
            field = value
            val menuItem = enter_private_key_toolbar.getMenu().findItem(R.id.next)
            if (value) {
                menuItem.setIcon(R.drawable.ic_action_next_enabled)
            } else {
                menuItem.setIcon(R.drawable.ic_action_next_disabled)
            }
        }

    companion object {
        fun newInstance(): BaseEnterPrivateKeyFragment {
            val fragment = BaseEnterPrivateKeyFragment()
            return fragment
        }
    }


    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        keyboardStateObserver = KeyboardStateObserver(view.enter_private_key_content_container)
        keyboardStateObserver.listener = {
            if (it) {
                enter_private_key_scroll.fullScroll(View.FOCUS_DOWN)
            }
        }

        view.enter_private_key_toolbar.setNavigationIcon(R.drawable.ic_action_close)
        view.enter_private_key_toolbar.setNavigationOnClickListener(View.OnClickListener { close() })
        view.enter_private_key_toolbar.inflateMenu(R.menu.forward)
        view.enter_private_key_toolbar.setOnMenuItemClickListener(this)

        view.enter_private_key_text.addTextChangedListener(object : EmptyTextWatcher {
            override fun onTextChanged(s: CharSequence, start: Int, before: Int, count: Int) {
                onPasswordChanged(s.toString())
            }
        })

        view.enter_private_key_title.setText(getTitle())
        view.enter_private_key_description.setText(getDescription())
        isNextEnabled = false

        KeyboardUtils.showKeyboard(view.enter_private_key_text)
        view.enter_private_key_text.setOnEditorActionListener { _, actionId, _ ->
            if (actionId == EditorInfo.IME_ACTION_DONE) {
                onNextClick(isNextEnabled, view.enter_private_key_text.text.toString())
                true
            } else {
                false
            }
        }
    }

    private fun onPasswordChanged(password: String) {
        if (password.isEmpty()) {
            isNextEnabled = false
        } else {
            isNextEnabled = canGoNext(password)
        }
        if (view?.enter_private_key_input_layout?.isErrorEnabled == true) {
            view?.enter_private_key_input_layout?.isErrorEnabled = false
        }
    }

    open fun canGoNext(password: String) = true

    fun showPrivateKeyError(error: String) {
        view?.enter_private_key_input_layout?.error = error
    }

    override fun onMenuItemClick(menuItem: MenuItem): Boolean {
        if (menuItem.itemId == R.id.next) {
            onNextClick(isNextEnabled, view?.enter_private_key_text?.text.toString())
            return true
        }
        return false
    }

    fun onNextClick(isNextEnabled: Boolean, privateKey: String) {
        if (isNextEnabled) {


            if(checkPrivateKey(privateKey)){
                addFragment(PickPasswordFragment.newInstance(null, privateKey))
            } else{
                showPrivateKeyError(getString(R.string.enter_private_key_error))
            }

        }
    }

    private fun checkPrivateKey(privateKeyString: String): Boolean {

        try{
            val cs = Credentials.create(privateKeyString)

            val ecKeyPair = cs.getEcKeyPair()

            if (ecKeyPair != null && ecKeyPair.publicKey != null) {
                return true
            }
        } catch(e: Exception){
            return false
        }


        return false
    }

    @StringRes
    fun getTitle() = R.string.enter_private_key_title

    @StringRes
    fun getDescription() = R.string.enter_private_key_description

    override fun layoutId() = R.layout.fragment_enter_private_key
}