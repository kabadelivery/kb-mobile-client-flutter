package tg.tmye.kaba.brave.one

import android.app.Activity
import android.content.Intent
import android.net.Uri
import androidx.activity.result.contract.ActivityResultContracts
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.lang.ref.WeakReference
import io.flutter.embedding.android.FlutterFragmentActivity

class PhotoPickerMethodChannelHandler(
    private val activityRef: WeakReference<FlutterFragmentActivity>
) : MethodChannel.MethodCallHandler {

    private var resultCallback: MethodChannel.Result? = null

    private val getContent =
        activityRef.get()?.registerForActivityResult(ActivityResultContracts.GetContent()) { uri: Uri? ->
            resultCallback?.success(uri?.toString())
        }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "pickMedia") {
            val fileType = call.argument<String>("file_type") ?: "image"
            resultCallback = result
            getContent?.launch("image/*")
        } else {
            result.notImplemented()
        }
    }
}
