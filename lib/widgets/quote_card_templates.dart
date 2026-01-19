import 'package:flutter/material.dart';
import '../models/quote_model.dart';

// Template 1: Gradient Background - COMPACT VERSION
class QuoteCardTemplate1 extends StatelessWidget {
  final Quote quote;

  const QuoteCardTemplate1({super.key, required this.quote});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      height: 450,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.purple, Colors.blue],
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          const Icon(Icons.format_quote, size: 50, color: Colors.white70),
          const SizedBox(height: 24),
          Expanded(
            child: Center(
              child: Text(
                quote.text,
                textAlign: TextAlign.center,
                maxLines: 8,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '— ${quote.author}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'QuoteVault',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// Template 2: Minimalist White - COMPACT VERSION
class QuoteCardTemplate2 extends StatelessWidget {
  final Quote quote;

  const QuoteCardTemplate2({super.key, required this.quote});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      height: 450,
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            width: 50,
            height: 3,
            color: Colors.black87,
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Center(
              child: Text(
                quote.text,
                textAlign: TextAlign.center,
                maxLines: 8,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            quote.author.toUpperCase(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 13,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'QUOTEVAULT',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 11,
              letterSpacing: 3,
            ),
          ),
        ],
      ),
    );
  }
}

// Template 3: Dark with Accent - COMPACT VERSION
class QuoteCardTemplate3 extends StatelessWidget {
  final Quote quote;

  const QuoteCardTemplate3({super.key, required this.quote});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      height: 450,
      decoration: const BoxDecoration(
        color: Color(0xFF1a1a1a),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              quote.category.toUpperCase(),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Text(
              '"${quote.text}"',
              maxLines: 8,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '— ${quote.author}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 12),
          const Text(
            'QuoteVault',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}