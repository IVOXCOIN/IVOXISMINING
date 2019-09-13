package com.myetherwallet.mewconnect.feature.main.adapter

import android.app.Activity
import android.view.View
import android.view.ViewGroup
import android.widget.*
import com.myetherwallet.mewconnect.R

class TokensListAdapter(private val context: Activity,
                        private val date: MutableList<String>,
                        private val amount: MutableList<String>,
                        private val paypal: MutableList<String>,
                        private val imgid: Int)
    : ArrayAdapter<String>(context, R.layout.list_item_token, date) {

    override fun getView(position: Int, view: View?, parent: ViewGroup): View {
        val inflater = context.layoutInflater
        val rowView = inflater.inflate(R.layout.list_item_token, null, true)

        val imageView = rowView.findViewById(R.id.icon) as ImageView
        val dateText = rowView.findViewById(R.id.date) as TextView
        val amountText = rowView.findViewById(R.id.amount) as TextView
        val paypalText = rowView.findViewById(R.id.paypal) as TextView

        imageView.setImageResource(imgid)
        dateText.text = date[position]
        amountText.text = amount[position]
        paypalText.text = paypal[position]

        return rowView
    }
}