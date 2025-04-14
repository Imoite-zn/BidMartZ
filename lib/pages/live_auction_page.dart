import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecomm_site/providers/auction_provider.dart';
import 'package:ecomm_site/components/live_auction_product_tile.dart';

class LiveAuctionPage extends StatefulWidget {
  const LiveAuctionPage({super.key});

  @override
  State<LiveAuctionPage> createState() => _LiveAuctionPageState();
}

class _LiveAuctionPageState extends State<LiveAuctionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Auctions'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              Provider.of<AuctionProvider>(context, listen: false)
                  .fetchActiveAuctions();
            },
          ),
        ],
      ),
      body: Consumer<AuctionProvider>(
        builder: (context, auctionProvider, child) {
          if (auctionProvider.isLoading && auctionProvider.activeAuctions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (auctionProvider.errorMessage != null && auctionProvider.activeAuctions.isEmpty) {
            return Center(
              child: Padding(
                 padding: const EdgeInsets.all(16.0),
                 child: Text(
                    'Error loading auctions: ${auctionProvider.errorMessage}',
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                 ),
              ),
            );
          }

          if (auctionProvider.activeAuctions.isEmpty) {
            return const Center(
              child: Text('No active auctions at the moment.'),
            );
          }

          return RefreshIndicator(
             onRefresh: auctionProvider.fetchActiveAuctions,
             child: ListView.builder(
               padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
               itemCount: auctionProvider.activeAuctions.length,
               itemBuilder: (context, index) {
                 final product = auctionProvider.activeAuctions[index];
                 return LiveAuctionProductTile(auctionProduct: product);
               },
             ),
          );
        },
      ),
    );
  }
}