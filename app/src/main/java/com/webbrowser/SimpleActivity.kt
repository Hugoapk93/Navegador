package com.webbrowser

import android.app.Activity
import android.os.Bundle
import android.widget.TextView

class SimpleActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Solo mostrar texto, nada más
        val textView = TextView(this)
        textView.text = "¡Web Browser Funciona!"
        setContentView(textView)
    }
}
