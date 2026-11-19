import 'package:apna_shop/features/products/domain/product.dart';

/// A common kirana item the shopkeeper can pick to start the add-product form.
/// Names only: there is no barcode, price or stock here, because those differ
/// from shop to shop (and a made-up barcode would open the wrong product).
class StarterItem {
  const StarterItem({
    required this.name,
    required this.nameHi,
    required this.unit,
    required this.category,
    this.brand,
  });

  /// Roman-script name, as shopkeepers write it. Stored as the product name.
  final String name;
  final String nameHi;
  final ProductUnit unit;
  final String category;
  final String? brand;
}

/// Loose goods sold by weight cannot be counted in whole numbers yet, so the
/// list uses packed sizes ("Toor Dal 1 kg", a packet).
const List<StarterItem> starterCatalog = [
  StarterItem(
    name: 'Wheat Atta 5 kg',
    nameHi: 'गेहूं का आटा 5 किलो',
    unit: ProductUnit.packet,
    category: 'Atta & Grains',
  ),
  StarterItem(
    name: 'Wheat Atta 10 kg',
    nameHi: 'गेहूं का आटा 10 किलो',
    unit: ProductUnit.packet,
    category: 'Atta & Grains',
  ),
  StarterItem(
    name: 'Besan 500 g',
    nameHi: 'बेसन 500 ग्राम',
    unit: ProductUnit.packet,
    category: 'Atta & Grains',
  ),
  StarterItem(
    name: 'Maida 1 kg',
    nameHi: 'मैदा 1 किलो',
    unit: ProductUnit.packet,
    category: 'Atta & Grains',
  ),
  StarterItem(
    name: 'Suji (Rava) 500 g',
    nameHi: 'सूजी (रवा) 500 ग्राम',
    unit: ProductUnit.packet,
    category: 'Atta & Grains',
  ),
  StarterItem(
    name: 'Poha 500 g',
    nameHi: 'पोहा 500 ग्राम',
    unit: ProductUnit.packet,
    category: 'Atta & Grains',
  ),
  StarterItem(
    name: 'Basmati Rice 1 kg',
    nameHi: 'बासमती चावल 1 किलो',
    unit: ProductUnit.packet,
    category: 'Atta & Grains',
  ),
  StarterItem(
    name: 'Rice 5 kg',
    nameHi: 'चावल 5 किलो',
    unit: ProductUnit.packet,
    category: 'Atta & Grains',
  ),
  StarterItem(
    name: 'Sabudana 500 g',
    nameHi: 'साबूदाना 500 ग्राम',
    unit: ProductUnit.packet,
    category: 'Atta & Grains',
  ),
  StarterItem(
    name: 'Daliya 500 g',
    nameHi: 'दलिया 500 ग्राम',
    unit: ProductUnit.packet,
    category: 'Atta & Grains',
  ),
  StarterItem(
    name: 'Vermicelli (Seviyan) 200 g',
    nameHi: 'सेवइयाँ 200 ग्राम',
    unit: ProductUnit.packet,
    category: 'Atta & Grains',
  ),
  StarterItem(
    name: 'Toor Dal 1 kg',
    nameHi: 'तुअर दाल 1 किलो',
    unit: ProductUnit.packet,
    category: 'Dal & Pulses',
  ),
  StarterItem(
    name: 'Moong Dal 500 g',
    nameHi: 'मूंग दाल 500 ग्राम',
    unit: ProductUnit.packet,
    category: 'Dal & Pulses',
  ),
  StarterItem(
    name: 'Chana Dal 1 kg',
    nameHi: 'चना दाल 1 किलो',
    unit: ProductUnit.packet,
    category: 'Dal & Pulses',
  ),
  StarterItem(
    name: 'Urad Dal 500 g',
    nameHi: 'उड़द दाल 500 ग्राम',
    unit: ProductUnit.packet,
    category: 'Dal & Pulses',
  ),
  StarterItem(
    name: 'Masoor Dal 500 g',
    nameHi: 'मसूर दाल 500 ग्राम',
    unit: ProductUnit.packet,
    category: 'Dal & Pulses',
  ),
  StarterItem(
    name: 'Kabuli Chana 500 g',
    nameHi: 'काबुली चना 500 ग्राम',
    unit: ProductUnit.packet,
    category: 'Dal & Pulses',
  ),
  StarterItem(
    name: 'Rajma 500 g',
    nameHi: 'राजमा 500 ग्राम',
    unit: ProductUnit.packet,
    category: 'Dal & Pulses',
  ),
  StarterItem(
    name: 'Green Moong 500 g',
    nameHi: 'साबुत मूंग 500 ग्राम',
    unit: ProductUnit.packet,
    category: 'Dal & Pulses',
  ),
  StarterItem(
    name: 'Dried Peas (Matar) 500 g',
    nameHi: 'सूखी मटर 500 ग्राम',
    unit: ProductUnit.packet,
    category: 'Dal & Pulses',
  ),
  StarterItem(
    name: 'Soyabean Oil 1 L',
    nameHi: 'सोयाबीन तेल 1 लीटर',
    unit: ProductUnit.bottle,
    category: 'Oil & Ghee',
  ),
  StarterItem(
    name: 'Mustard Oil 1 L',
    nameHi: 'सरसों का तेल 1 लीटर',
    unit: ProductUnit.bottle,
    category: 'Oil & Ghee',
  ),
  StarterItem(
    name: 'Groundnut Oil 1 L',
    nameHi: 'मूंगफली तेल 1 लीटर',
    unit: ProductUnit.bottle,
    category: 'Oil & Ghee',
  ),
  StarterItem(
    name: 'Refined Oil Pouch 1 L',
    nameHi: 'रिफाइंड तेल पाउच 1 लीटर',
    unit: ProductUnit.packet,
    category: 'Oil & Ghee',
  ),
  StarterItem(
    name: 'Ghee 500 ml',
    nameHi: 'घी 500 मिली',
    unit: ProductUnit.pack,
    category: 'Oil & Ghee',
  ),
  StarterItem(
    name: 'Ghee 1 L',
    nameHi: 'घी 1 लीटर',
    unit: ProductUnit.pack,
    category: 'Oil & Ghee',
  ),
  StarterItem(
    name: 'Vanaspati 1 kg',
    nameHi: 'वनस्पति 1 किलो',
    unit: ProductUnit.pack,
    category: 'Oil & Ghee',
  ),
  StarterItem(
    name: 'Turmeric Powder 100 g',
    nameHi: 'हल्दी पाउडर 100 ग्राम',
    unit: ProductUnit.packet,
    category: 'Spices',
  ),
  StarterItem(
    name: 'Red Chilli Powder 100 g',
    nameHi: 'लाल मिर्च पाउडर 100 ग्राम',
    unit: ProductUnit.packet,
    category: 'Spices',
  ),
  StarterItem(
    name: 'Coriander Powder 100 g',
    nameHi: 'धनिया पाउडर 100 ग्राम',
    unit: ProductUnit.packet,
    category: 'Spices',
  ),
  StarterItem(
    name: 'Garam Masala 50 g',
    nameHi: 'गरम मसाला 50 ग्राम',
    unit: ProductUnit.packet,
    category: 'Spices',
  ),
  StarterItem(
    name: 'Cumin (Jeera) 100 g',
    nameHi: 'जीरा 100 ग्राम',
    unit: ProductUnit.packet,
    category: 'Spices',
  ),
  StarterItem(
    name: 'Mustard Seeds (Rai) 100 g',
    nameHi: 'राई 100 ग्राम',
    unit: ProductUnit.packet,
    category: 'Spices',
  ),
  StarterItem(
    name: 'Black Pepper 50 g',
    nameHi: 'काली मिर्च 50 ग्राम',
    unit: ProductUnit.packet,
    category: 'Spices',
  ),
  StarterItem(
    name: 'Hing 10 g',
    nameHi: 'हींग 10 ग्राम',
    unit: ProductUnit.packet,
    category: 'Spices',
  ),
  StarterItem(
    name: 'Kitchen King Masala 100 g',
    nameHi: 'किचन किंग मसाला 100 ग्राम',
    unit: ProductUnit.packet,
    category: 'Spices',
  ),
  StarterItem(
    name: 'Chaat Masala 50 g',
    nameHi: 'चाट मसाला 50 ग्राम',
    unit: ProductUnit.packet,
    category: 'Spices',
  ),
  StarterItem(
    name: 'Pav Bhaji Masala 50 g',
    nameHi: 'पाव भाजी मसाला 50 ग्राम',
    unit: ProductUnit.packet,
    category: 'Spices',
  ),
  StarterItem(
    name: 'Ajwain 100 g',
    nameHi: 'अजवाइन 100 ग्राम',
    unit: ProductUnit.packet,
    category: 'Spices',
  ),
  StarterItem(
    name: 'Methi Dana 100 g',
    nameHi: 'मेथी दाना 100 ग्राम',
    unit: ProductUnit.packet,
    category: 'Spices',
  ),
  StarterItem(
    name: 'Cardamom (Elaichi) 50 g',
    nameHi: 'इलायची 50 ग्राम',
    unit: ProductUnit.packet,
    category: 'Spices',
  ),
  StarterItem(
    name: 'Cloves (Laung) 50 g',
    nameHi: 'लौंग 50 ग्राम',
    unit: ProductUnit.packet,
    category: 'Spices',
  ),
  StarterItem(
    name: 'Sugar 1 kg',
    nameHi: 'चीनी 1 किलो',
    unit: ProductUnit.packet,
    category: 'Sugar, Salt & Tea',
  ),
  StarterItem(
    name: 'Iodised Salt 1 kg',
    nameHi: 'आयोडीन नमक 1 किलो',
    unit: ProductUnit.packet,
    category: 'Sugar, Salt & Tea',
    brand: 'Tata',
  ),
  StarterItem(
    name: 'Rock Salt (Sendha Namak) 500 g',
    nameHi: 'सेंधा नमक 500 ग्राम',
    unit: ProductUnit.packet,
    category: 'Sugar, Salt & Tea',
  ),
  StarterItem(
    name: 'Jaggery (Gud) 1 kg',
    nameHi: 'गुड़ 1 किलो',
    unit: ProductUnit.packet,
    category: 'Sugar, Salt & Tea',
  ),
  StarterItem(
    name: 'Tea 250 g',
    nameHi: 'चाय पत्ती 250 ग्राम',
    unit: ProductUnit.packet,
    category: 'Sugar, Salt & Tea',
  ),
  StarterItem(
    name: 'Tea 100 g',
    nameHi: 'चाय पत्ती 100 ग्राम',
    unit: ProductUnit.packet,
    category: 'Sugar, Salt & Tea',
  ),
  StarterItem(
    name: 'Instant Coffee 50 g',
    nameHi: 'इंस्टेंट कॉफ़ी 50 ग्राम',
    unit: ProductUnit.bottle,
    category: 'Sugar, Salt & Tea',
  ),
  StarterItem(
    name: 'Parle-G',
    nameHi: 'पारले-जी',
    unit: ProductUnit.packet,
    category: 'Biscuits',
    brand: 'Parle',
  ),
  StarterItem(
    name: 'Good Day',
    nameHi: 'गुड डे',
    unit: ProductUnit.packet,
    category: 'Biscuits',
    brand: 'Britannia',
  ),
  StarterItem(
    name: 'Marie Gold',
    nameHi: 'मैरी गोल्ड',
    unit: ProductUnit.packet,
    category: 'Biscuits',
    brand: 'Britannia',
  ),
  StarterItem(
    name: 'Monaco',
    nameHi: 'मोनैको',
    unit: ProductUnit.packet,
    category: 'Biscuits',
    brand: 'Parle',
  ),
  StarterItem(
    name: 'Hide & Seek',
    nameHi: 'हाइड एंड सीक',
    unit: ProductUnit.packet,
    category: 'Biscuits',
    brand: 'Parle',
  ),
  StarterItem(
    name: 'Bourbon',
    nameHi: 'बॉर्बन',
    unit: ProductUnit.packet,
    category: 'Biscuits',
    brand: 'Britannia',
  ),
  StarterItem(
    name: '50-50',
    nameHi: '50-50',
    unit: ProductUnit.packet,
    category: 'Biscuits',
    brand: 'Britannia',
  ),
  StarterItem(
    name: 'Rusk',
    nameHi: 'रस्क',
    unit: ProductUnit.packet,
    category: 'Biscuits',
  ),
  StarterItem(
    name: 'Ratlami Sev 200 g',
    nameHi: 'रतलामी सेव 200 ग्राम',
    unit: ProductUnit.packet,
    category: 'Namkeen & Snacks',
  ),
  StarterItem(
    name: 'Indori Mixture 200 g',
    nameHi: 'इंदौरी मिक्सचर 200 ग्राम',
    unit: ProductUnit.packet,
    category: 'Namkeen & Snacks',
  ),
  StarterItem(
    name: 'Aloo Bhujia 200 g',
    nameHi: 'आलू भुजिया 200 ग्राम',
    unit: ProductUnit.packet,
    category: 'Namkeen & Snacks',
  ),
  StarterItem(
    name: 'Moong Dal Namkeen 200 g',
    nameHi: 'मूंग दाल नमकीन 200 ग्राम',
    unit: ProductUnit.packet,
    category: 'Namkeen & Snacks',
  ),
  StarterItem(
    name: 'Papad 200 g',
    nameHi: 'पापड़ 200 ग्राम',
    unit: ProductUnit.packet,
    category: 'Namkeen & Snacks',
  ),
  StarterItem(
    name: 'Yellow Diamond Chips',
    nameHi: 'येलो डायमंड चिप्स',
    unit: ProductUnit.packet,
    category: 'Namkeen & Snacks',
    brand: 'Yellow Diamond',
  ),
  StarterItem(
    name: 'Yellow Diamond Rings',
    nameHi: 'येलो डायमंड रिंग्स',
    unit: ProductUnit.packet,
    category: 'Namkeen & Snacks',
    brand: 'Yellow Diamond',
  ),
  StarterItem(
    name: 'Kurkure',
    nameHi: 'कुरकुरे',
    unit: ProductUnit.packet,
    category: 'Namkeen & Snacks',
    brand: 'Kurkure',
  ),
  StarterItem(
    name: 'Lay\'s Chips',
    nameHi: 'लेज़ चिप्स',
    unit: ProductUnit.packet,
    category: 'Namkeen & Snacks',
    brand: 'Lay\'s',
  ),
  StarterItem(
    name: 'Instant Noodles',
    nameHi: 'इंस्टेंट नूडल्स',
    unit: ProductUnit.packet,
    category: 'Instant & Packaged Food',
    brand: 'Maggi',
  ),
  StarterItem(
    name: 'Pasta 200 g',
    nameHi: 'पास्ता 200 ग्राम',
    unit: ProductUnit.packet,
    category: 'Instant & Packaged Food',
  ),
  StarterItem(
    name: 'Oats 500 g',
    nameHi: 'ओट्स 500 ग्राम',
    unit: ProductUnit.packet,
    category: 'Instant & Packaged Food',
  ),
  StarterItem(
    name: 'Corn Flakes 500 g',
    nameHi: 'कॉर्न फ्लेक्स 500 ग्राम',
    unit: ProductUnit.packet,
    category: 'Instant & Packaged Food',
  ),
  StarterItem(
    name: 'Tomato Ketchup 500 g',
    nameHi: 'टमाटर केचप 500 ग्राम',
    unit: ProductUnit.bottle,
    category: 'Instant & Packaged Food',
  ),
  StarterItem(
    name: 'Mixed Fruit Jam 500 g',
    nameHi: 'मिक्स फ्रूट जैम 500 ग्राम',
    unit: ProductUnit.bottle,
    category: 'Instant & Packaged Food',
  ),
  StarterItem(
    name: 'Pickle (Achar) 500 g',
    nameHi: 'अचार 500 ग्राम',
    unit: ProductUnit.bottle,
    category: 'Instant & Packaged Food',
  ),
  StarterItem(
    name: 'Milk Pouch 500 ml',
    nameHi: 'दूध पाउच 500 मिली',
    unit: ProductUnit.packet,
    category: 'Dairy & Bakery',
  ),
  StarterItem(
    name: 'Curd (Dahi) 400 g',
    nameHi: 'दही 400 ग्राम',
    unit: ProductUnit.pack,
    category: 'Dairy & Bakery',
  ),
  StarterItem(
    name: 'Butter 100 g',
    nameHi: 'मक्खन 100 ग्राम',
    unit: ProductUnit.pack,
    category: 'Dairy & Bakery',
    brand: 'Amul',
  ),
  StarterItem(
    name: 'Paneer 200 g',
    nameHi: 'पनीर 200 ग्राम',
    unit: ProductUnit.pack,
    category: 'Dairy & Bakery',
  ),
  StarterItem(
    name: 'Cheese Slices',
    nameHi: 'चीज़ स्लाइस',
    unit: ProductUnit.pack,
    category: 'Dairy & Bakery',
    brand: 'Amul',
  ),
  StarterItem(
    name: 'Bread',
    nameHi: 'ब्रेड',
    unit: ProductUnit.packet,
    category: 'Dairy & Bakery',
  ),
  StarterItem(
    name: 'Eggs (Tray of 30)',
    nameHi: 'अंडे (30 की ट्रे)',
    unit: ProductUnit.pack,
    category: 'Dairy & Bakery',
  ),
  StarterItem(
    name: 'Cold Drink 600 ml',
    nameHi: 'कोल्ड ड्रिंक 600 मिली',
    unit: ProductUnit.bottle,
    category: 'Beverages',
  ),
  StarterItem(
    name: 'Cold Drink 2 L',
    nameHi: 'कोल्ड ड्रिंक 2 लीटर',
    unit: ProductUnit.bottle,
    category: 'Beverages',
  ),
  StarterItem(
    name: 'Packaged Water 1 L',
    nameHi: 'पैकेज्ड पानी 1 लीटर',
    unit: ProductUnit.bottle,
    category: 'Beverages',
  ),
  StarterItem(
    name: 'Soda 600 ml',
    nameHi: 'सोडा 600 मिली',
    unit: ProductUnit.bottle,
    category: 'Beverages',
  ),
  StarterItem(
    name: 'Mango Drink 200 ml',
    nameHi: 'आम का जूस 200 मिली',
    unit: ProductUnit.packet,
    category: 'Beverages',
    brand: 'Frooti',
  ),
  StarterItem(
    name: 'Energy Drink',
    nameHi: 'एनर्जी ड्रिंक',
    unit: ProductUnit.bottle,
    category: 'Beverages',
  ),
  StarterItem(
    name: 'Detergent Powder 1 kg',
    nameHi: 'कपड़े धोने का पाउडर 1 किलो',
    unit: ProductUnit.packet,
    category: 'Cleaning & Household',
  ),
  StarterItem(
    name: 'Detergent Bar',
    nameHi: 'डिटर्जेंट बार',
    unit: ProductUnit.piece,
    category: 'Cleaning & Household',
  ),
  StarterItem(
    name: 'Dishwash Bar',
    nameHi: 'बर्तन धोने की बार',
    unit: ProductUnit.piece,
    category: 'Cleaning & Household',
    brand: 'Vim',
  ),
  StarterItem(
    name: 'Dishwash Liquid 500 ml',
    nameHi: 'डिशवॉश लिक्विड 500 मिली',
    unit: ProductUnit.bottle,
    category: 'Cleaning & Household',
  ),
  StarterItem(
    name: 'Phenyl 1 L',
    nameHi: 'फिनाइल 1 लीटर',
    unit: ProductUnit.bottle,
    category: 'Cleaning & Household',
  ),
  StarterItem(
    name: 'Toilet Cleaner 500 ml',
    nameHi: 'टॉयलेट क्लीनर 500 मिली',
    unit: ProductUnit.bottle,
    category: 'Cleaning & Household',
  ),
  StarterItem(
    name: 'Floor Cleaner 1 L',
    nameHi: 'फर्श क्लीनर 1 लीटर',
    unit: ProductUnit.bottle,
    category: 'Cleaning & Household',
  ),
  StarterItem(
    name: 'Matchbox',
    nameHi: 'माचिस',
    unit: ProductUnit.pack,
    category: 'Cleaning & Household',
  ),
  StarterItem(
    name: 'Agarbatti',
    nameHi: 'अगरबत्ती',
    unit: ProductUnit.packet,
    category: 'Cleaning & Household',
  ),
  StarterItem(
    name: 'Camphor (Kapoor)',
    nameHi: 'कपूर',
    unit: ProductUnit.packet,
    category: 'Cleaning & Household',
  ),
  StarterItem(
    name: 'Candles',
    nameHi: 'मोमबत्ती',
    unit: ProductUnit.packet,
    category: 'Cleaning & Household',
  ),
  StarterItem(
    name: 'Mosquito Coil',
    nameHi: 'मच्छर कॉइल',
    unit: ProductUnit.packet,
    category: 'Cleaning & Household',
  ),
  StarterItem(
    name: 'Garbage Bags',
    nameHi: 'कचरा थैली',
    unit: ProductUnit.packet,
    category: 'Cleaning & Household',
  ),
  StarterItem(
    name: 'Bathing Soap',
    nameHi: 'नहाने का साबुन',
    unit: ProductUnit.piece,
    category: 'Personal Care',
  ),
  StarterItem(
    name: 'Toothpaste 100 g',
    nameHi: 'टूथपेस्ट 100 ग्राम',
    unit: ProductUnit.pack,
    category: 'Personal Care',
  ),
  StarterItem(
    name: 'Toothbrush',
    nameHi: 'टूथब्रश',
    unit: ProductUnit.piece,
    category: 'Personal Care',
  ),
  StarterItem(
    name: 'Shampoo Sachet',
    nameHi: 'शैम्पू सैशे',
    unit: ProductUnit.packet,
    category: 'Personal Care',
  ),
  StarterItem(
    name: 'Shampoo Bottle 180 ml',
    nameHi: 'शैम्पू बोतल 180 मिली',
    unit: ProductUnit.bottle,
    category: 'Personal Care',
  ),
  StarterItem(
    name: 'Hair Oil 100 ml',
    nameHi: 'बालों का तेल 100 मिली',
    unit: ProductUnit.bottle,
    category: 'Personal Care',
  ),
  StarterItem(
    name: 'Coconut Oil 200 ml',
    nameHi: 'नारियल तेल 200 मिली',
    unit: ProductUnit.bottle,
    category: 'Personal Care',
  ),
  StarterItem(
    name: 'Talcum Powder 100 g',
    nameHi: 'टैल्कम पाउडर 100 ग्राम',
    unit: ProductUnit.pack,
    category: 'Personal Care',
  ),
  StarterItem(
    name: 'Face Wash',
    nameHi: 'फेस वॉश',
    unit: ProductUnit.pack,
    category: 'Personal Care',
  ),
  StarterItem(
    name: 'Sanitary Pads',
    nameHi: 'सैनिटरी पैड',
    unit: ProductUnit.packet,
    category: 'Personal Care',
  ),
  StarterItem(
    name: 'Razor',
    nameHi: 'रेज़र',
    unit: ProductUnit.piece,
    category: 'Personal Care',
  ),
  StarterItem(
    name: 'Toffee Pack',
    nameHi: 'टॉफ़ी पैक',
    unit: ProductUnit.packet,
    category: 'Candy & Chocolate',
  ),
  StarterItem(
    name: 'Chocolate Bar',
    nameHi: 'चॉकलेट बार',
    unit: ProductUnit.piece,
    category: 'Candy & Chocolate',
  ),
  StarterItem(
    name: 'Chewing Gum',
    nameHi: 'च्युइंग गम',
    unit: ProductUnit.packet,
    category: 'Candy & Chocolate',
  ),
];

/// Items matching [query] in name, Hindi name, brand or category. Empty query
/// returns everything, in catalog order.
List<StarterItem> filterStarterItems(String query, {String? category}) {
  final needle = query.trim().toLowerCase();
  return [
    for (final item in starterCatalog)
      if ((category == null || item.category == category) &&
          (needle.isEmpty ||
              item.name.toLowerCase().contains(needle) ||
              item.nameHi.contains(needle) ||
              (item.brand?.toLowerCase().contains(needle) ?? false) ||
              item.category.toLowerCase().contains(needle)))
        item,
  ];
}

/// Categories in catalog order, without repeats.
List<String> get starterCategories {
  final seen = <String>[];
  for (final item in starterCatalog) {
    if (!seen.contains(item.category)) seen.add(item.category);
  }
  return seen;
}
