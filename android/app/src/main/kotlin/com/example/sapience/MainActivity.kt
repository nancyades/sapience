package com.sapiencepublication.sapience

import android.os.Bundle
import android.view.WindowManager.LayoutParams.FLAG_SECURE
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.addFlags(FLAG_SECURE)
    }
}



//withou screen record
/*package com.example.sapience

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity()*/
