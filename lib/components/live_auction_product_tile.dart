import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date/time formatting
import '../models/auction_product.dart';

class LiveAuctionProductTile extends StatefulWidget {
  final AuctionProduct auctionProduct;

  const LiveAuctionProductTile({super.key, required this.auctionProduct});

  @override
  State<LiveAuctionProductTile> createState() => _LiveAuctionProductTileState();
}

class _LiveAuctionProductTileState extends State<LiveAuctionProductTile> {
  Timer? _timer;
  Duration? _remainingTime;

  @override
  void initState() {
    super.initState();
    _updateRemainingTime();
    if (_remainingTime != null && _remainingTime!.isNegative == false) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateRemainingTime() {
    final now = DateTime.now();
    if (widget.auctionProduct.endTime.isAfter(now)) {
       _remainingTime = widget.auctionProduct.endTime.difference(now);
    } else {
       _remainingTime = Duration.zero; // Auction ended
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
         _updateRemainingTime();
         if (_remainingTime == Duration.zero) {
            timer.cancel(); // Stop timer when auction ends
            // Optionally: Trigger a refresh or callback if needed
         }
      });
    });
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) return "Ended";
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image
          Container(
             height: 220,
             child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4.0)),
                child: Image.network(
                  widget.auctionProduct.imageUrl,
                  fit: BoxFit.cover,
                  // Loading and error builders for better UX
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(Icons.error_outline, color: Colors.red, size: 40)),
                ),
             ),
          ),
          // Details Section
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.auctionProduct.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.auctionProduct.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Price and Timer Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(
                           'Current Bid:',
                           style: Theme.of(context).textTheme.labelMedium,
                         ),
                         Text(
                           numberFormat.format(widget.auctionProduct.currentPrice),
                           style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold),
                         ),
                       ],
                    ),
                    // Timer Display
                    Column(
                       crossAxisAlignment: CrossAxisAlignment.end,
                       children: [
                          Text(
                            'Time Left:',
                             style: Theme.of(context).textTheme.labelMedium,
                          ),
                          Text(
                            _remainingTime != null ? _formatDuration(_remainingTime!) : "--:--:--",
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: _remainingTime == Duration.zero ? Colors.red : Colors.green[700],
                                fontWeight: FontWeight.bold),
                          ),
                       ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Place Bid Button (Full Width)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _remainingTime == Duration.zero ? null : () {
                      // TODO: Implement Bidding Navigation/Dialog
                      print('Bid on: ${widget.auctionProduct.name}');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Bidding on ${widget.auctionProduct.name} (Not implemented)')),
                      );
                    },
                    child: const Text('Place Bid'),
                    style: ElevatedButton.styleFrom(
                       padding: EdgeInsets.symmetric(vertical: 12)
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 