import 'package:apna_shop/features/products/domain/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

DateTime? _toDate(Object? value) => value is Timestamp ? value.toDate() : null;

int _toInt(Object? value) => value is num ? value.toInt() : 0;

Product productFromMap({
  required String storeId,
  required String id,
  required Map<String, dynamic> data,
}) {
  final name = (data['name'] as String?) ?? '';
  return Product(
    id: id,
    storeId: storeId,
    name: name,
    normalizedName: (data['normalizedName'] as String?) ?? name.toLowerCase(),
    unit: ProductUnit.tryParse(data['unit'] as String?) ?? ProductUnit.piece,
    purchasePricePaise: _toInt(data['purchasePricePaise']),
    sellingPricePaise: _toInt(data['sellingPricePaise']),
    openingQuantity: _toInt(data['openingQuantity']),
    currentQuantity: _toInt(data['currentQuantity']),
    lowStockThreshold: _toInt(data['lowStockThreshold']),
    barcode: data['barcode'] as String?,
    sku: data['sku'] as String?,
    category: data['category'] as String?,
    brand: data['brand'] as String?,
    imageUrl: data['imageUrl'] as String?,
    isActive: (data['isActive'] as bool?) ?? true,
    createdAt: _toDate(data['createdAt']),
    updatedAt: _toDate(data['updatedAt']),
  );
}
