import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:col_to_do/main.dart';

// Cliente HTTP simulado para evitar fallos de red al cargar avatares.
class MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient();
  }
}

class _MockHttpClient implements HttpClient {
  @override
  bool autoUncompress = true;
  @override
  Duration? connectionTimeout;
  @override
  Duration idleTimeout = const Duration(seconds: 15);
  @override
  int? maxConnectionsPerHost;
  @override
  String? userAgent;

  @override
  void addCredentials(
      Uri url, String realm, HttpClientCredentials credentials) {}
  @override
  void addProxyCredentials(String host, int port, String realm,
      HttpClientCredentials credentials) {}
  @override
  set authenticate(
      Future<bool> Function(Uri url, String scheme, String realm)? f) {}
  @override
  set authenticateProxy(
      Future<bool> Function(
              String host, int port, String scheme, String realm)?
          f) {}
  @override
  void close({bool force = false}) {}
  @override
  Future<HttpClientRequest> connectionFactory(
      Uri url, String? proxyHost, int? proxyPort) {
    throw UnimplementedError();
  }

  @override
  set findProxy(String Function(Uri url)? f) {}
  @override
  set keyLog(Function(String line)? callback) {}

  @override
  Future<HttpClientRequest> open(
      String method, String host, int port, String path) {
    return Future.value(_MockHttpClientRequest());
  }

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) {
    return Future.value(_MockHttpClientRequest());
  }

  @override
  Future<HttpClientRequest> get(String host, int port, String path) =>
      open('get', host, port, path);
  @override
  Future<HttpClientRequest> getUrl(Uri url) => openUrl('get', url);
  @override
  Future<HttpClientRequest> post(String host, int port, String path) =>
      open('post', host, port, path);
  @override
  Future<HttpClientRequest> postUrl(Uri url) => openUrl('post', url);
  @override
  Future<HttpClientRequest> put(String host, int port, String path) =>
      open('put', host, port, path);
  @override
  Future<HttpClientRequest> putUrl(Uri url) => openUrl('put', url);
  @override
  Future<HttpClientRequest> delete(String host, int port, String path) =>
      open('delete', host, port, path);
  @override
  Future<HttpClientRequest> deleteUrl(Uri url) => openUrl('delete', url);
  @override
  Future<HttpClientRequest> head(String host, int port, String path) =>
      open('head', host, port, path);
  @override
  Future<HttpClientRequest> headUrl(Uri url) => openUrl('head', url);
  @override
  Future<HttpClientRequest> patch(String host, int port, String path) =>
      open('patch', host, port, path);
  @override
  Future<HttpClientRequest> patchUrl(Uri url) => openUrl('patch', url);
}

class _MockHttpClientRequest implements HttpClientRequest {
  @override
  Encoding encoding = utf8;
  @override
  int get contentLength => 0;
  @override
  set contentLength(int value) {}
  @override
  bool get followRedirects => true;
  @override
  set followRedirects(bool value) {}
  @override
  int get maxRedirects => 5;
  @override
  set maxRedirects(int value) {}
  @override
  bool get persistentConnection => true;
  @override
  set persistentConnection(bool value) {}
  @override
  HttpHeaders get headers => _MockHttpHeaders();
  @override
  Future<HttpClientResponse> get done =>
      Future.value(_MockHttpClientResponse());

  @override
  void add(List<int> data) {}
  @override
  void addError(Object error, [StackTrace? stackTrace]) {}
  @override
  Future<void> addStream(Stream<List<int>> stream) => Future.value();
  @override
  Future<HttpClientResponse> close() =>
      Future.value(_MockHttpClientResponse());
  @override
  void write(Object? obj) {}
  @override
  void writeAll(Iterable<Object?> objects, [String separator = '']) {}
  @override
  void writeCharCode(int charCode) {}
  @override
  void writeln([Object? obj = '']) {}
  @override
  HttpConnectionInfo? get connectionInfo => null;
  @override
  List<Cookie> get cookies => [];
  @override
  String get method => 'GET';
  @override
  Uri get uri => Uri.parse('http://localhost');
}

class _MockHttpHeaders implements HttpHeaders {
  @override
  List<String>? operator [](String name) => null;
  @override
  set chunkedTransferEncoding(bool value) {}
  @override
  bool get chunkedTransferEncoding => false;
  @override
  set contentLength(int value) {}
  @override
  int get contentLength => 0;
  @override
  set contentType(ContentType? value) {}
  @override
  ContentType? get contentType => null;
  @override
  set date(DateTime? value) {}
  @override
  DateTime? get date => null;
  @override
  set expires(DateTime? value) {}
  @override
  DateTime? get expires => null;
  @override
  set host(String? value) {}
  @override
  String? get host => null;
  @override
  set ifModifiedSince(DateTime? value) {}
  @override
  DateTime? get ifModifiedSince => null;
  @override
  set persistentConnection(bool value) {}
  @override
  bool get persistentConnection => true;
  @override
  set port(int? value) {}
  @override
  int? get port => null;

  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}
  @override
  void clear() {}
  @override
  void forEach(void Function(String name, List<String> values) action) {}
  @override
  String? value(String name) => null;
  @override
  void noFolding(String name) {}
  @override
  void remove(String name, Object value) {}
  @override
  void removeAll(String name) {}
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}
}

class _MockHttpClientResponse extends Stream<List<int>>
    implements HttpClientResponse {
  @override
  int get contentLength => 0;
  @override
  int get statusCode => 200;
  @override
  String get reasonPhrase => 'OK';
  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;
  @override
  List<Cookie> get cookies => [];
  @override
  bool get isRedirect => false;
  @override
  HttpHeaders get headers => _MockHttpHeaders();

  @override
  Future<RedirectInfo> redirect(
      [String? method, Uri? url, bool? followRedirects]) {
    throw UnimplementedError();
  }

  @override
  Future<HttpClientResponse> redirectLimit() {
    throw UnimplementedError();
  }

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    // Retorna una imagen transparente simulada de 1x1 píxeles.
    final emptyImage = [
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
      0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
      0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
      0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
      0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
      0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82
    ];
    return Stream<List<int>>.fromIterable([emptyImage]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  HttpConnectionInfo? get connectionInfo => null;
}

void main() {
  setUpAll(() {
    HttpOverrides.global = MockHttpOverrides();
  });

  testWidgets('Prueba de humo del layout principal',
      (WidgetTester tester) async {
    // Construye la aplicación dentro de un ProviderScope para Riverpod.
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // Espera a que se rendericen los frames iniciales.
    await tester.pumpAndSettle();

    // Verifica que el título de la aplicación esté presente.
    expect(find.text('Kinetic Sync'), findsOneWidget);

    // Verifica que la sección de proyectos se muestre por defecto.
    expect(find.text('My Projects'), findsOneWidget);
  });
}
