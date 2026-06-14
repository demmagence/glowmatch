import 'dart:io';
import 'package:flutter/material.dart';

Widget buildProductImage(String? imageUrl) {
  if (imageUrl == null || imageUrl.isEmpty) {
    return const Icon(
      Icons.dry_cleaning_outlined,
      size: 48,
      color: Colors.grey,
    );
  }
  final isLocal =
      !imageUrl.startsWith('http') && !imageUrl.startsWith('assets');
  final isAsset = imageUrl.startsWith('assets');
  if (isLocal) {
    return Image.file(
      File(imageUrl),
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(
          Icons.dry_cleaning_outlined,
          size: 48,
          color: Colors.grey,
        );
      },
    );
  } else if (isAsset) {
    return Image.asset(
      imageUrl,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(
          Icons.dry_cleaning_outlined,
          size: 48,
          color: Colors.grey,
        );
      },
    );
  } else {
    return Image.network(
      imageUrl,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(
          Icons.dry_cleaning_outlined,
          size: 48,
          color: Colors.grey,
        );
      },
    );
  }
}
