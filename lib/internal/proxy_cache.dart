import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

/// The DefaultCacheManager that can be easily used directly. The code of
/// this implementation can be used as inspiration for more complex cache
/// managers.
class ProxyCacheManager extends CacheManager with ImageCacheManager {
  static const key = 'libCachedImageData';
  static ProxyCacheManager? _instance;

  static String currentProxyAddress = '';


  @override
  ProxyCacheManager._(String proxyAddress) : super(
      proxyAddress.isEmpty
          ? Config(key)
          : Config(key, fileService: HttpFileService(
              httpClient: buildProxyClient(proxyAddress),
            )),
    );

  factory ProxyCacheManager({String proxyAddress = ''}) {
  if (_instance == null || currentProxyAddress != proxyAddress) {
    _instance?.emptyCache(); // 可选：切换代理时清缓存
    _instance = ProxyCacheManager._(proxyAddress);
    currentProxyAddress = proxyAddress;
  }
  return _instance!;
}

  static http.Client buildProxyClient(String proxyAddress) {
    final ioClient = HttpClient();
    ioClient.findProxy = (uri) => 'PROXY $proxyAddress';
    ioClient.badCertificateCallback = (cert, host, port) => true;
    return IOClient(ioClient);
  }

}
