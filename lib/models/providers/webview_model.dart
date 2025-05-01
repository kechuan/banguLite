import 'package:bangu_lite/internal/hive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewModel extends ChangeNotifier {

  WebViewModel() {
    initModel();
  }

  WebViewEnvironment? webViewEnvironment;

  InAppWebViewController? webViewController;

  InAppWebViewSettings settings = InAppWebViewSettings(
    isInspectable: kDebugMode,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    iframeAllow: "camera; microphone",
    iframeAllowFullscreen: true
  );

  //仅限移动端
  PullToRefreshController? pullToRefreshController;
  late String currentSurfingUrl;

  void initModel() async {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
        final availableVersion = await WebViewEnvironment.getAvailableVersion();
        assert(
          availableVersion != null,
          'Failed to find an installed WebView2 Runtime or non-stable Microsoft Edge installation.'
        );

        webViewEnvironment = await WebViewEnvironment.create(
            settings: WebViewEnvironmentSettings(userDataFolder: MyHive.filesDir.path));
      }

      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
      }


    }



}