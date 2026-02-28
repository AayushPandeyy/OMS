import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:oms/features/menu_management/domain/entities/food_item.dart';

class AddFoodItemPage extends StatefulWidget {
  const AddFoodItemPage({Key? key}) : super(key: key);

  @override
  State<AddFoodItemPage> createState() => _AddFoodItemPageState();
}

class _AddFoodItemPageState extends State<AddFoodItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _foodNameController = TextEditingController();
  final _categoryIdController = TextEditingController();
  final _priceController = TextEditingController();

  String _generatedFoodId = '';
  bool _isAvailable = true;

  @override
  void initState() {
    super.initState();
    _generateFoodId();
  }

  void _generateFoodId() {
    setState(() {
      _generatedFoodId =
          'FOOD-${const Uuid().v4().substring(0, 8).toUpperCase()}';
    });
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _categoryIdController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _saveFoodItem() {
    if (_formKey.currentState!.validate()) {
      final foodItem = FoodItem(
        foodId: _generatedFoodId,
        foodName: _foodNameController.text.trim(),
        categoryId: _categoryIdController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        isAvailable: _isAvailable,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Food item "${foodItem.foodName}" added successfully!'),
          backgroundColor: const Color(0xFFFC5E03),
        ),
      );

      Navigator.pop(context, foodItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFFFC5E03),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Add Food Item',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Create New Food Item',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Add a new item to your menu',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),

              // Auto-generated ID Display
              _buildIdCard(),
              const SizedBox(height: 24),

              // Food Name
              _buildLabel('Food Name'),
              _buildTextField(
                controller: _foodNameController,
                hintText: 'e.g. Margherita Pizza, Cappuccino',
                icon: Icons.restaurant,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Food name is required';
                  }
                  if (value.trim().length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Category ID
              _buildLabel('Category ID'),
              _buildTextField(
                controller: _categoryIdController,
                hintText: 'e.g. CAT-12345678',
                icon: Icons.category,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Category ID is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Price
              _buildLabel('Price'),
              _buildPriceField(),
              const SizedBox(height: 24),

              // Availability Toggle
              _buildAvailabilityCard(),
              const SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveFoodItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFC5E03),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Save Food Item',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIdCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFC5E03).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFC5E03).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.tag, color: Color(0xFFFC5E03), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Food ID',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _generatedFoodId,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  'Auto-generated',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[400],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFFC5E03)),
            onPressed: _generateFoodId,
            tooltip: 'Generate new ID',
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _isAvailable
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _isAvailable ? Icons.check_circle : Icons.cancel,
              color: _isAvailable ? Colors.green : Colors.red,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Availability',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isAvailable ? 'Item is available' : 'Item is not available',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Switch(
            value: _isAvailable,
            onChanged: (value) {
              setState(() => _isAvailable = value);
            },
            activeColor: const Color(0xFFFC5E03),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: const TextStyle(fontSize: 15, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
        prefixIcon: Icon(icon, size: 20, color: Colors.grey[500]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFC5E03), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        errorStyle: const TextStyle(fontSize: 12, color: Colors.red),
      ),
    );
  }

  Widget _buildPriceField() {
    return TextFormField(
      controller: _priceController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Price is required';
        }
        final price = double.tryParse(value);
        if (price == null) {
          return 'Please enter a valid price';
        }
        if (price <= 0) {
          return 'Price must be greater than 0';
        }
        return null;
      },
      style: const TextStyle(fontSize: 15, color: Colors.black87),
      decoration: InputDecoration(
        hintText: 'e.g. 299.99',
        hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
        prefixIcon: Icon(
          Icons.currency_rupee,
          size: 20,
          color: Colors.grey[500],
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFC5E03), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        errorStyle: const TextStyle(fontSize: 12, color: Colors.red),
      ),
    );
  }
}
