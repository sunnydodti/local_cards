package com.sunnydodti.local_cards

import io.flutter.embedding.android.FlutterFragmentActivity
import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.os.Build
import android.os.Bundle
import android.content.ClipDescription
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterFragmentActivity() {
	private val CHANNEL = "clipboard_service"

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)
		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
			if (call.method == "copySensitive") {
				val text = call.argument<String>("text") ?: ""
				val clipboard = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
				val clip = if (Build.VERSION.SDK_INT >= 33) {
					val description = ClipDescription("Sensitive", arrayOf("text/plain"))
					description.extras = android.os.PersistableBundle().apply {
						putBoolean(ClipDescription.EXTRA_IS_SENSITIVE, true)
					}
					ClipData(description, ClipData.Item(text))
				} else {
					ClipData.newPlainText("Sensitive", text)
				}
				clipboard.setPrimaryClip(clip)
				result.success(null)
			} else {
				result.notImplemented()
			}
		}
	}
}
