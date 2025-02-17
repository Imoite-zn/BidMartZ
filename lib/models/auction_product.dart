import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

//class for an auction product
class AuctionProduct {
  final String name;
  final String description;
  final int price;
  final File image;
  final int auctionDuration;

  AuctionProduct({
    required this.name, 
    required this.description, 
    required this.image, 
    required this.auctionDuration, 
    required this.price});
}