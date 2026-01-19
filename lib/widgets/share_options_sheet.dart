import 'package:flutter/material.dart';
import '../models/quote_model.dart';
import '../services/share_service.dart';
import 'quote_card_templates.dart';

class ShareOptionsSheet extends StatelessWidget {
  final Quote quote;

  const ShareOptionsSheet({super.key, required this.quote});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Share Quote',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.text_fields),
            title: const Text('Share as Text'),
            onTap: () {
              Navigator.pop(context);
              ShareService.shareAsText(quote);
            },
          ),
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text('Share as Image'),
            subtitle: const Text('Choose a template'),
            onTap: () {
              Navigator.pop(context);
              _showTemplateSelection(context, quote);
            },
          ),
        ],
      ),
    );
  }

  void _showTemplateSelection(BuildContext context, Quote quote) {
    showDialog(
      context: context,
      builder: (context) => TemplateSelectionDialog(quote: quote),
    );
  }
}

class TemplateSelectionDialog extends StatefulWidget {
  final Quote quote;

  const TemplateSelectionDialog({super.key, required this.quote});

  @override
  State<TemplateSelectionDialog> createState() =>
      _TemplateSelectionDialogState();
}

class _TemplateSelectionDialogState extends State<TemplateSelectionDialog> {
  int selectedTemplate = 0;
  final List<GlobalKey> cardKeys = [
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).dialogBackgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose Template',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Preview Cards
            SizedBox(
              height: 200,
              child: PageView(
                onPageChanged: (index) {
                  setState(() {
                    selectedTemplate = index;
                  });
                },
                children: [
                  _buildPreviewCard(QuoteCardTemplate1(quote: widget.quote)),
                  _buildPreviewCard(QuoteCardTemplate2(quote: widget.quote)),
                  _buildPreviewCard(QuoteCardTemplate3(quote: widget.quote)),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Dots Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selectedTemplate == index
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                  ),
                );
              }),
            ),

            const SizedBox(height: 12),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      await ShareService.saveToGallery(
                        context,
                        cardKeys[selectedTemplate],
                      );
                    },
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('Save'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      await ShareService.shareAsImage(
                        context,
                        widget.quote,
                        cardKeys[selectedTemplate],
                      );
                    },
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text('Share'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),

            // Hidden full-size cards for capture - FIXED with UnconstrainedBox
            Offstage(
              offstage: true,
              child: UnconstrainedBox(
                child: Column(
                  children: [
                    RepaintBoundary(
                      key: cardKeys[0],
                      child: QuoteCardTemplate1(quote: widget.quote),
                    ),
                    RepaintBoundary(
                      key: cardKeys[1],
                      child: QuoteCardTemplate2(quote: widget.quote),
                    ),
                    RepaintBoundary(
                      key: cardKeys[2],
                      child: QuoteCardTemplate3(quote: widget.quote),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard(Widget card) {
    return Center(
      child: FittedBox(
        fit: BoxFit.contain,
        child: card,
      ),
    );
  }
}