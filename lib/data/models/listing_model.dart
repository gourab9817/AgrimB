import 'package:flutter/material.dart';

class ListingModel {
  final String id;
  final String farmerId;
  final String name;
  final String imagePath;
  final String location;
  final String quantity;
  final String price;
  final String qualityIndicator;
  final String listingDate;
  final String quality;
  final String description;

  ListingModel({
    required this.id,
    required this.farmerId,
    required this.name,
    required this.imagePath,
    required this.location,
    required this.quantity,
    required this.price,
    required this.qualityIndicator,
    required this.listingDate,
    required this.quality,
    required this.description,
  });

  factory ListingModel.fromMap(Map<String, dynamic> map) {
    return ListingModel(
      id: map['id'] ?? '',
      farmerId: map['farmerId'] ?? '',
      name: map['name'] ?? '',
      imagePath: map['imagePath'] ?? '',
      location: map['location'] ?? '',
      quantity: map['quantity']?.toString() ?? '',
      price: map['price']?.toString() ?? '',
      qualityIndicator: map['qualityIndicator'] ?? '',
      listingDate: map['listedDate']?.toString() ?? '',
      quality: map['quality'] ?? '',
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'farmerId': farmerId,
      'name': name,
      'imagePath': imagePath,
      'location': location,
      'quantity': quantity,
      'price': price,
      'qualityIndicator': qualityIndicator,
      'listedDate': listingDate,
      'quality': quality,
      'description': description,
    };
  }
} 