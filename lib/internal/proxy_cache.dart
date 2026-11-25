import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

/// The DefaultCacheManager that can be easily used directly. The code of
/// this implementation can be used as inspiration for more complex cache
/// managers.
class ProxyCacheManager extends CacheManager with ImageCacheManager {
  static const key = 'libCachedImageData';
  static ProxyCacheManager? instance;

  static String currentProxyAddress = '';

  final http.Client? httpClient;

  ProxyCacheManager.create(String proxyAddress, this.httpClient) : super(
    proxyAddress.isEmpty || httpClient == null
      ? Config(key)
      : Config(
        key,
        fileService: HttpFileService(
          httpClient: httpClient,
        ),
      ),
  );

  factory ProxyCacheManager({String proxyAddress = ''}) {
    if (instance == null || currentProxyAddress != proxyAddress) {
      instance?.httpClient?.close();

      final http.Client? client = proxyAddress.isEmpty ? null : buildProxyClient(proxyAddress);

      instance = ProxyCacheManager.create(proxyAddress, client);
      currentProxyAddress = proxyAddress;
    }

    return instance!;
  }

  static http.Client buildProxyClient(String proxyAddress) {
    final ioClient = HttpClient();

    ioClient.findProxy = (uri) {
      if (proxyAddress.isNotEmpty) return 'PROXY $proxyAddress';
      return 'DIRECT';
    };

    ioClient.badCertificateCallback = (cert, host, port) => true;
    return IOClient(ioClient);
  }

}
