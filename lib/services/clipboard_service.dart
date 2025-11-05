import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class ClipboardService {
  static const MethodChannel _channel = MethodChannel('clipboard_service');
  static Timer? _clearTimer;

  /// Copies [text] to the clipboard, marks as sensitive if possible, and clears after [timeout].
  static Future<void> copySensitive(String text,
      {Duration timeout = const Duration(seconds: 30)}) async {
    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod('copySensitive', {
          'text': text,
        });
      } catch (e, st) {
        debugPrint('[ClipboardService] Android copySensitive failed: $e\n$st');
        await Clipboard.setData(ClipboardData(text: text));
      }
    } else {
      await Clipboard.setData(ClipboardData(text: text));
    }
    _clearTimer?.cancel();
    _clearTimer = Timer(timeout, clearClipboard);
  }

  /// Clears the clipboard.
  static Future<void> clearClipboard() async {
    await Clipboard.setData(const ClipboardData(text: ''));
    debugPrint('[ClipboardService] Clipboard cleared');
  }
}
