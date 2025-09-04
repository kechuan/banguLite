package io.flutter.banguLite

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity(){
	private val banguLiteChannel = "io.flutter.bangulite/channel";

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)
		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, banguLiteChannel).setMethodCallHandler {
            // 注意: 这个回调是在主线程上执行的。如果你的操作耗时，应该切换到后台线程。
            call, result ->
            if (call.method == "test") {
                // 返回数字 30
                result.success(30)
            } 
			
			else {
                // 如果 Flutter 调用了未知的方法
                result.notImplemented()
            }
        }
	}
}
