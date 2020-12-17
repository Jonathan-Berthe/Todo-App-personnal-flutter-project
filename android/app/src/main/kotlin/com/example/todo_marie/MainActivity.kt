package com.example.todo_marie
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.TimeZone



class MainActivity: FlutterActivity() {

    private val CHANNEL = "timezone.name"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
      call, result ->
      if (call.method == "getTimeZoneName") {

      			val temp = getTimeZoneName()
          		result.success(temp)
      		} else {
        		result.notImplemented()
      		}
    }
  } 

  private fun getTimeZoneName(): String {
    val stringToSend: String = TimeZone.getDefault().getID()
    return stringToSend
  }

}
