package com.graceedit.graceedit

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        ThumbnailPlugin(applicationContext, flutterEngine)
        ExportPlugin(applicationContext, flutterEngine)
        MediaPickerPlugin(this, flutterEngine)
        SystemPlugin(this, flutterEngine)
    }
}
