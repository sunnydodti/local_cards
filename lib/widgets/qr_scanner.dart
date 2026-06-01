// Conditional export: use mobile implementation normally, web implementation when building for web.
export 'qr_scanner_mobile.dart' if (dart.library.html) 'qr_scanner_web.dart';
