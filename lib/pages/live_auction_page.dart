import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ecomm_site/models/auction_product.dart';

class LiveAuctionPage extends StatefulWidget {
  const LiveAuctionPage({super.key});

  @override
  State<LiveAuctionPage> createState() => _LiveAuctionPageState();
}

class _LiveAuctionPageState extends State<LiveAuctionPage> {
  List<AuctionProduct> _auctionProducts = [];
  Timer? _auctionTimer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Auctions'),
      ),
      body: _auctionProducts.isEmpty
          ? Center(
              child: Text('No active auctions at the moment'),
            )
          : ListView.builder(
              itemCount: _auctionProducts.length,
              itemBuilder: (context, index) {
                final product = _auctionProducts[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Image.file(
                        product.image,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(product.description),
                            SizedBox(height: 8),
                            Text(
                              'Current Bid: \$${product.price}',
                              style: TextStyle(
                                fontSize: 18,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                // TODO: Implement bidding functionality
                              },
                              child: Text('Place Bid'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}