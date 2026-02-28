import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:oms/features/table_management/domain/entities/restaurant_table.dart';

class AddNewTablePage extends StatefulWidget {
  const AddNewTablePage({Key? key}) : super(key: key);

  @override
  State<AddNewTablePage> createState() => _AddNewTablePageState();
}

class _AddNewTablePageState extends State<AddNewTablePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameOrNumberController = TextEditingController();
  final _capacityController = TextEditingController();
  final _cafeIdController = TextEditingController();

  String _generatedTableId = '';

  @override
  void initState() {
    super.initState();
    _generateTableId();
  }

  void _generateTableId() {
    setState(() {
      _generatedTableId =
          'TBL-${const Uuid().v4().substring(0, 8).toUpperCase()}';
    });
  }

  @override
  void dispose() {
    _nameOrNumberController.dispose();
    _capacityController.dispose();
    _cafeIdController.dispose();
    super.dispose();
  }

  void _saveTable() {
    if (_formKey.currentState!.validate()) {
      final table = RestaurantTable(
        tableId: _generatedTableId,
        nameOrNumber: _nameOrNumberController.text.trim(),
        capacity: int.parse(_capacityController.text.trim()),
        cafeId: _cafeIdController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Table "${table.nameOrNumber}" added successfully!'),
          backgroundColor: const Color(0xFFFC5E03),
        ),
      );

      Navigator.pop(context, table);
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
          'Add New Table',
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
                'Create New Table',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Add a new table to your restaurant',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),

              // Auto-generated ID Display
              _buildIdCard(),
              const SizedBox(height: 24),

              // Table Name/Number
              _buildLabel('Table Name / Number'),
              _buildTextField(
                controller: _nameOrNumberController,
                hintText: 'e.g. Table 1, Window Table, T-01',
                icon: Icons.table_restaurant,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Table name/number is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Capacity
              _buildLabel('Capacity (Persons)'),
              _buildCapacitySelector(),
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
                  onPressed: _saveTable,
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
                        'Save Table',
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
                  'Table ID',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _generatedTableId,
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
            onPressed: _generateTableId,
            tooltip: 'Generate new ID',
          ),
        ],
      ),
    );
  }

  Widget _buildCapacitySelector() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.people, size: 20, color: Colors.grey[500]),
              const SizedBox(width: 12),
              Text(
                'How many people can sit?',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _capacityController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Capacity is required';
              }
              final capacity = int.tryParse(value);
              if (capacity == null || capacity < 1) {
                return 'Capacity must be at least 1';
              }
              if (capacity > 50) {
                return 'Capacity cannot exceed 50';
              }
              return null;
            },
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: '4',
              hintStyle: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[300],
              ),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFFFC5E03),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              errorStyle: const TextStyle(fontSize: 11, color: Colors.red),
            ),
          ),
          const SizedBox(height: 12),
          // Quick select buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [2, 4, 6, 8, 10].map((capacity) {
              return InkWell(
                onTap: () {
                  _capacityController.text = capacity.toString();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    '$capacity',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              );
            }).toList(),
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
