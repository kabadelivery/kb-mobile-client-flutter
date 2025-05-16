package tg.tmye.kaba.brave.one

import android.net.Uri
import android.os.Bundle
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts

class MainActivity : FlutterFragmentActivity() {

    companion object {
        private const val PHOTO_PICKER_METHOD_CHANNEL = "photo_picker_method_channel"
    }

    private lateinit var getImageContent: ActivityResultLauncher<String>
    private var imageResultCallback: MethodChannel.Result? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Register the activity result launcher here
        getImageContent = registerForActivityResult(ActivityResultContracts.GetContent()) { uri: Uri? ->
            imageResultCallback?.success(uri?.toString())
            imageResultCallback = null // Clean up the callback
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PHOTO_PICKER_METHOD_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "pickMedia" -> {
                        imageResultCallback = result
                        val fileType = call.argument<String>("file_type") ?: "image"
                        getImageContent.launch("$fileType/*")
                    }

                    "readFileBytes" -> {
                        val uriStr = call.argument<String>("uri")
                        if (uriStr != null) {
                            try {
                                val inputStream = contentResolver.openInputStream(Uri.parse(uriStr))
                                val bytes = inputStream?.readBytes()
                                inputStream?.close()
                                result.success(bytes)
                            } catch (e: Exception) {
                                result.error("READ_ERROR", "Failed to read bytes: ${e.localizedMessage}", null)
                            }
                        } else {
                            result.error("INVALID_URI", "URI is null", null)
                        }
                    }

                    else -> {
                        result.notImplemented()
                    }
                }
            }
    }
}
