import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

// Class for an auction product (represents data fetched from Supabase)
class AuctionProduct {
  final String id;        // UUID from Supabase
  final String name;
  final String description;
  final int startingPrice;
  final int currentPrice; // Current highest bid
  final String imageUrl;    // URL from Supabase Storage
  final DateTime endTime;   // When the auction ends
  final String status;      // e.g., 'active', 'ended'
  final String sellerId;    // UUID of the seller
  // Removed File image and auctionDuration as they are less relevant
  // for the shared model representing DB state.

  AuctionProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.startingPrice,
    required this.currentPrice,
    required this.imageUrl,
    required this.endTime,
    required this.status,
    required this.sellerId,
  });

  // Optional: Factory constructor to create from Supabase response (Map)
  factory AuctionProduct.fromJson(Map<String, dynamic> json) {
    return AuctionProduct(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      startingPrice: (json['starting_price'] as num).toInt(),
      currentPrice: (json['current_price'] as num).toInt(),
      imageUrl: json['image_url'] as String,
      endTime: DateTime.parse(json['end_time'] as String),
      status: json['status'] as String,
      sellerId: json['seller_id'] as String, // Assuming seller_id is returned
    );
  }
}