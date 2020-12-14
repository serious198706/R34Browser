package com.r34.browser

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

import android.os.Environment
import android.util.Log
import android.os.*
import android.Manifest

import okhttp3.*
import okio.BufferedSink
import okio.Okio
import okio.buffer
import okio.sink
import java.io.File
import java.io.IOException

class MainActivity: FlutterActivity() {
    private val CHANNEL_PLATFORM = "com.r34.browser/platform"
    private val handler = Handler(Looper.getMainLooper())

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_PLATFORM)
        channel.setMethodCallHandler { methodCall, result ->
            if ("saveFile" == methodCall.method) {
                try {
                    requestPermissions(arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE), 999)

                    val path = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES).absolutePath + File.separator + "r34"
                    val url = methodCall.argument<String>("url") as String
                    val t = url.split("/")
                    val fileName = t[t.size - 1]

                    val request: Request = Request.Builder().url(url).build()
                    OkHttpClient().newCall(request).enqueue(object : Callback {
                        override fun onFailure(call: Call, e: IOException) {
                            e.printStackTrace()
                        }

                        override fun onResponse(call: Call, response: Response) {
                            try {
                                val downloadedFile = File(path, fileName)
                                val sink: BufferedSink = downloadedFile.sink().buffer()
                                sink.writeAll(response.body!!.source())
                                sink.close()
                                response.close()

                                handler.post {
                                    channel.invokeMethod("saveFinish", null)
                                }
                            } catch (e: Exception) {
                            }
                        }
                    })
                } catch (e: Exception) {
                    e.printStackTrace()
                    Log.d("TTTTTTTTTT", "download error: {e.message}")
                }
            }
        }
    }
}
