package com.myetherwallet.mewconnect.feature.main.adapter

import android.app.Activity
import android.view.View
import android.view.ViewGroup
import android.widget.*
import com.myetherwallet.mewconnect.R

class TokenListAdapter(private val context: Activity,
                       private val titles: MutableList<String>,
                       private val strings: MutableList<String>)
    : ArrayAdapter<String>(context, R.layout.list_item_token_content, titles) {

    override fun getView(position: Int, view: View?, parent: ViewGroup): View {
        val inflater = context.layoutInflater
        val rowView = inflater.inflate(R.layout.list_item_token_content, null, true)

        val titleText = rowView.findViewById(R.id.title) as TextView
        val descriptionText = rowView.findViewById(R.id.description) as TextView

        titleText.text = titles[position]
        descriptionText.text = strings[position]

        return rowView
    }
}