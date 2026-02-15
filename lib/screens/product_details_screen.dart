import 'package:flutter/material.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  // ตัวแปรเก็บไซส์ที่เลือก (เริ่มหหที่ไซส์หหหห 8)
  int _selectedSizeIndex = 2;
  final List<String> _sizes = ['6', '7', '8', '9', '10'];

  // สีหลักของแอพ (สีแดงอมส้มตามรูป)
  final Color primaryColor = const Color(0xFFFF5555);
  final Color TextColor = const Color(0xFF223263);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // --- 1. App Bar ด้านบน ---
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: TextColor),
          onPressed: () => Navigator.pop(context), // กดแล้วย้อนกลับ
        ),
        title: Text(
          "Product Details",
          style: TextStyle(color: TextColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          // ไอคอนตะกร้าพร้อมตัวเลข (Badge)
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart_outlined, color: TextColor, size: 28),
                onPressed: () {},
              ),
              Positioned(
                right: 5,
                top: 5,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: const Text(
                    '2', // จำนวนสินค้าในตะกร้า
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
        ],
      ),

      // --- 2. เนื้อหาตรงกลาง ---
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // รูปสินค้า
            Center(
              child: Image.network(
                'https://static.nike.com/a/images/t_PDP_1280_v1/f_auto,q_auto:eco/9f28b9c5-0423-4a4c-96d7-259345634040/air-max-270-mens-shoes-KkLcGR.png', // รูปตัวอย่างรองเท้า Nike
                height: 250,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 20),

            // จุดบอกตำแหน่งรูปภาพ (Image Indicators)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIndicator(isActive: true),
                _buildIndicator(isActive: false),
                _buildIndicator(isActive: false),
              ],
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ชื่อสินค้า
                  Text(
                    "Nike Air 270 React",
                    style: TextStyle(
                      color: TextColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // ราคา
                  Text(
                    "\$120.00",
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // หัวข้อ Select Size
                  Text(
                    "Select Size",
                    style: TextStyle(
                      color: TextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // --- 3. ปุ่มเลือกไซส์ (Size Selector) ---
                  Row(
                    children: List.generate(_sizes.length, (index) {
                      return _buildSizeButton(
                        text: _sizes[index],
                        isSelected: _selectedSizeIndex == index,
                        onTap: () {
                          setState(() {
                            _selectedSizeIndex = index;
                          });
                        },
                      );
                    }),
                  ),

                  const SizedBox(height: 25),

                  // รายละเอียดสินค้า
                  Text(
                    "The Nike Air 270 React it's comfortable and lightweight, with a soft foam midsole and a Max Air unit in the heel for cushioning.",
                    style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),

      // --- 4. ปุ่มด้านล่างสุด (Bottom Button) ---
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            // โค้ดเมื่อกดปุ่ม Add To Cart
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("เพิ่มไซส์ ${_sizes[_selectedSizeIndex]} ลงตะกร้าแล้ว!")),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text(
            "Add To Cart",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }

  // Widget ย่อย: ปุ่มเลือกไซส์
  Widget _buildSizeButton({required String text, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade600,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // Widget ย่อย: จุดบอกตำแหน่งรูป
  Widget _buildIndicator({required bool isActive}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 12 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? primaryColor : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}