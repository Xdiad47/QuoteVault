import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/quote_model.dart';

class ShareService {
  // Share quote as text
  static Future<void> shareAsText(Quote quote) async {
    final text = '"${quote.text}"\n\n— ${quote.author}';
    await Share.share(text, subject: 'Quote from QuoteVault');
  }

  // Generate and share quote card as image
  static Future<void> shareAsImage(
      BuildContext context,
      Quote quote,
      GlobalKey cardKey,
      ) async {
    try {
      // Show loading
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Generating image...')),
        );
      }

      // Wait for the widget to be fully rendered
      await Future.delayed(const Duration(milliseconds: 500));

      // Capture the widget as image
      RenderRepaintBoundary? boundary =
      cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        throw Exception('Could not find widget to capture');
      }

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);

      // Convert to byte data
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Failed to convert image to bytes');
      }

      final pngBytes = byteData.buffer.asUint8List();

      // Save to temporary directory
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/quote_${DateTime.now().millisecondsSinceEpoch}.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(pngBytes);

      // Share the image
      await Share.shareXFiles(
        [XFile(imagePath)],
        text: 'Quote from QuoteVault',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
      }
    } catch (e) {
      print('ERROR sharing image: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Save image to gallery
  static Future<void> saveToGallery(
      BuildContext context,
      GlobalKey cardKey,
      ) async {
    try {
      // Show loading
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saving image...')),
        );
      }

      // Wait for rendering
      await Future.delayed(const Duration(milliseconds: 500));

      RenderRepaintBoundary? boundary =
      cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        throw Exception('Could not find widget to capture');
      }

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);

      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Failed to convert image to bytes');
      }

      final pngBytes = byteData.buffer.asUint8List();

      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/quote_${DateTime.now().millisecondsSinceEpoch}.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(pngBytes);

      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved to ${imagePath}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('ERROR saving image: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
