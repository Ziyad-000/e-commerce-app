import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirebaseSeeder {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> seedDatabase() async {
    try {
      if (kDebugMode) {
        debugPrint('🌱 Starting database seeding...');
      }

      await seedCategories();
      await seedProducts();

      if (kDebugMode) {
        debugPrint('✅ Database seeded successfully!');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error seeding database: $e');
      }
    }
  }

  static Future<void> seedCategories() async {
    if (kDebugMode) {
      debugPrint('📂 Seeding categories...');
    }

    final categories = [
      {
        'id': 'men',
        'name': 'Men',
        'imageUrl':
            'https://images.pexels.com/photos/1689731/pexels-photo-1689731.jpeg?auto=compress&cs=tinysrgb&w=600',
        'productCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'women',
        'name': 'Women',
        'imageUrl':
            'https://images.pexels.com/photos/7679720/pexels-photo-7679720.jpeg?auto=compress&cs=tinysrgb&w=600',
        'productCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'kids',
        'name': 'Kids',
        'imageUrl':
            'https://images.pexels.com/photos/8844880/pexels-photo-8844880.jpeg?auto=compress&cs=tinysrgb&w=600',
        'productCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'accessories',
        'name': 'Accessories',
        'imageUrl':
            'https://images.pexels.com/photos/1152077/pexels-photo-1152077.jpeg?auto=compress&cs=tinysrgb&w=600',
        'productCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (var category in categories) {
      final docRef = _firestore
          .collection('categories')
          .doc(category['id'] as String);

      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        await docRef.set(category);
        if (kDebugMode) {
          debugPrint('  ✓ Added category: ${category['name']}');
        }
      } else {
        if (kDebugMode) {
          debugPrint('  - Category already exists: ${category['name']}');
        }
      }
    }

    if (kDebugMode) {
      debugPrint('✅ Categories seeding completed');
    }
  }

  static Future<void> seedProducts() async {
    if (kDebugMode) {
      debugPrint('📦 Seeding products...');
    }

    final products = [
      {
        'id': 'product1',
        'name': 'Premium Black T-Shirt',
        'description':
            'High-quality cotton t-shirt with modern fit. Perfect for casual wear.',
        'price': 29.99,
        'oldPrice': 39.99,
        'imageUrl':
            'https://images.pexels.com/photos/6311579/pexels-photo-6311579.jpeg?auto=compress&cs=tinysrgb&w=800',
        'category': 'Men',
        'rating': 4.8,
        'reviewCount': 324,
        'discount': 25,
        'finalPrice': 29.99,
        'stock': 15,
        'sizes': ['XS', 'S', 'M', 'L', 'XL'],
        'isFeatured': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'product2',
        'name': 'Classic Denim Jeans',
        'description': 'Comfortable stretch denim jeans for everyday wear.',
        'price': 89.99,
        'oldPrice': 119.99,
        'imageUrl':
            'https://images.pexels.com/photos/1598507/pexels-photo-1598507.jpeg?auto=compress&cs=tinysrgb&w=800',
        'category': 'Men',
        'rating': 4.6,
        'reviewCount': 198,
        'discount': 25,
        'finalPrice': 89.99,
        'stock': 8,
        'sizes': ['28', '30', '32', '34', '36'],
        'isFeatured': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'product3',
        'name': 'Stylish Men\'s Jacket',
        'description': 'Water-resistant jacket perfect for all seasons.',
        'price': 199.99,
        'oldPrice': 249.99,
        'imageUrl':
            'https://images.pexels.com/photos/1183266/pexels-photo-1183266.jpeg?auto=compress&cs=tinysrgb&w=800',
        'category': 'Men',
        'rating': 4.9,
        'reviewCount': 87,
        'discount': 20,
        'finalPrice': 199.99,
        'stock': 0,
        'sizes': ['S', 'M', 'L', 'XL'],
        'isFeatured': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'product4',
        'name': 'Cozy Knit Sweater',
        'description': 'Soft knit sweater to keep you warm and stylish.',
        'price': 69.99,
        'oldPrice': 89.99,
        'imageUrl':
            'https://images.pexels.com/photos/7679720/pexels-photo-7679720.jpeg?auto=compress&cs=tinysrgb&w=800',
        'category': 'Women',
        'rating': 4.3,
        'reviewCount': 156,
        'discount': 22,
        'finalPrice': 69.99,
        'stock': 12,
        'sizes': ['S', 'M', 'L', 'XL'],
        'isFeatured': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'product5',
        'name': 'Summer Floral Dress',
        'description': 'Beautiful floral print dress perfect for summer.',
        'price': 79.99,
        'oldPrice': 99.99,
        'imageUrl':
            'https://images.pexels.com/photos/985635/pexels-photo-985635.jpeg?auto=compress&cs=tinysrgb&w=800',
        'category': 'Women',
        'rating': 4.7,
        'reviewCount': 243,
        'discount': 20,
        'finalPrice': 79.99,
        'stock': 20,
        'sizes': ['XS', 'S', 'M', 'L'],
        'isFeatured': false,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'product6',
        'name': 'Elegant Evening Gown',
        'description': 'Stunning evening dress for special occasions.',
        'price': 149.99,
        'oldPrice': 199.99,
        'imageUrl':
            'https://images.pexels.com/photos/1721558/pexels-photo-1721558.jpeg?auto=compress&cs=tinysrgb&w=800',
        'category': 'Women',
        'rating': 4.9,
        'reviewCount': 67,
        'discount': 25,
        'finalPrice': 149.99,
        'stock': 5,
        'sizes': ['S', 'M', 'L'],
        'isFeatured': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'product7',
        'name': 'Kids Colorful Hoodie',
        'description': 'Comfortable and colorful hoodie for kids.',
        'price': 39.99,
        'oldPrice': 49.99,
        'imageUrl':
            'https://images.pexels.com/photos/8844880/pexels-photo-8844880.jpeg?auto=compress&cs=tinysrgb&w=800',
        'category': 'Kids',
        'rating': 4.5,
        'reviewCount': 89,
        'discount': 20,
        'finalPrice': 39.99,
        'stock': 25,
        'sizes': ['4-5Y', '6-7Y', '8-9Y', '10-11Y'],
        'isFeatured': false,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'product8',
        'name': 'Leather Crossbody Bag',
        'description': 'Genuine leather crossbody bag with adjustable strap.',
        'price': 89.99,
        'oldPrice': 119.99,
        'imageUrl':
            'https://images.pexels.com/photos/1152077/pexels-photo-1152077.jpeg?auto=compress&cs=tinysrgb&w=800',
        'category': 'Accessories',
        'rating': 4.6,
        'reviewCount': 134,
        'discount': 25,
        'finalPrice': 89.99,
        'stock': 10,
        'isFeatured': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (var product in products) {
      final docRef = _firestore
          .collection('products')
          .doc(product['id'] as String);

      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        await docRef.set(product);
        if (kDebugMode) {
          debugPrint('  ✓ Added product: ${product['name']}');
        }
      } else {
        if (kDebugMode) {
          debugPrint('  - Product already exists: ${product['name']}');
        }
      }
    }

    if (kDebugMode) {
      debugPrint('✅ Products seeding completed');
    }
  }

  static Future<void> clearDatabase() async {
    if (kDebugMode) {
      debugPrint('🗑️ Clearing database...');
    }

    try {
      final productsSnapshot = await _firestore.collection('products').get();
      for (var doc in productsSnapshot.docs) {
        await doc.reference.delete();
        if (kDebugMode) {
          debugPrint('  ✓ Deleted product: ${doc.id}');
        }
      }

      final categoriesSnapshot = await _firestore
          .collection('categories')
          .get();
      for (var doc in categoriesSnapshot.docs) {
        await doc.reference.delete();
        if (kDebugMode) {
          debugPrint('  ✓ Deleted category: ${doc.id}');
        }
      }

      if (kDebugMode) {
        debugPrint('✅ Database cleared successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error clearing database: $e');
      }
    }
  }
}
