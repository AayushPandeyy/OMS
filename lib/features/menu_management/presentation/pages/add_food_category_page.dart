import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:oms/features/menu_management/domain/entities/food_category.dart';

class AddFoodCategoryPage extends StatefulWidget {
  const AddFoodCategoryPage({Key? key}) : super(key: key);

  @override
  State<AddFoodCategoryPage> createState() => _AddFoodCategoryPageState();
}

class _AddFoodCategoryPageState extends State<AddFoodCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _categoryNameController = TextEditingController();
  final _cafeIdController = TextEditingController();

  String _generatedCategoryId = '';

  @override
  void initState() {
    super.initState();
    _generateCategoryId();
  }

  void _generateCategoryId() {
    setState(() {
      _generatedCategoryId =
          'CAT-${const Uuid().v4().substring(0, 8).toUpperCase()}';
    });
  }

  @override
  void dispose() {
    _categoryNameController.dispose();
    _cafeIdController.dispose();
    super.dispose();
  }

  void _saveCategory() {
    if (_formKey.currentState!.validate()) {
      final category = FoodCategory(
        categoryId: _generatedCategoryId,
        categoryName: _categoryNameController.text.trim(),
        cafeId: _cafeIdController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Category "${category.categoryName}" added successfully!',
          ),
          backgroundColor: const Color(0xFFFC5E03),
        ),
      );

      Navigator.pop(context, category);
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
          'Add Food Category',
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
                'Create New Category',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Add a new food category to organize your menu',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),

              // Auto-generated ID Display
              _buildIdCard(),
              const SizedBox(height: 24),

              // Category Name
              _buildLabel('Category Name'),
              _buildTextField(
                controller: _categoryNameController,
                hintText: 'e.g. Breakfast, Drinks, Desserts',
                icon: Icons.category,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Category name is required';
                  }
                  if (value.trim().length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Cafe ID
              _buildLabel('Cafe ID'),
              _buildTextField(
                controller: _cafeIdController,
                hintText: 'e.g. CAFE-001',
                icon: Icons.store,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Cafe ID is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveCategory,
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
                        'Save Category',
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
                  'Category ID',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _generatedCategoryId,
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
            onPressed: _generateCategoryId,
            tooltip: 'Generate new ID',
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
}
