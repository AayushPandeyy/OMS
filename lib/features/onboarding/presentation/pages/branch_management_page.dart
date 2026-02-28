import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oms/core/widgets/step_indicator.dart';
import 'package:oms/features/onboarding/domain/entities/branch.dart';
import 'package:oms/features/onboarding/domain/entities/onboarding_flow_data.dart';
import 'package:oms/features/onboarding/presentation/pages/operational_setup_page.dart';

class BranchManagementPage extends StatefulWidget {
  final bool hasMultipleBranches;
  final OnboardingFlowData onboardingData;

  const BranchManagementPage({
    Key? key,
    required this.hasMultipleBranches,
    this.onboardingData = const OnboardingFlowData(),
  }) : super(key: key);

  @override
  State<BranchManagementPage> createState() => _BranchManagementPageState();
}

class _BranchManagementPageState extends State<BranchManagementPage> {
  static const String _headOfficeKey = 'head_office';

  final List<Branch> _branches = [];
  Branch? _headOffice;
  late final bool _allowMultipleBranches;
  final Map<String, TextEditingController> _nameControllers = {};
  final Map<String, TextEditingController> _addressControllers = {};
  final _totalTablesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final planType = (widget.onboardingData.planType ?? '').toUpperCase();
    final planSupportsMultiple = planType != 'STARTER';
    _allowMultipleBranches = widget.hasMultipleBranches && planSupportsMultiple;

    if (!_allowMultipleBranches) {
      final branch = Branch(name: '', address: '', isHeadOffice: false);
      _branches.add(branch);
      _registerBranchControllers(branch);
    }

    // Restore previous value
    final existingTables = widget.onboardingData.totalTables;
    if (existingTables != null) {
      _totalTablesController.text = existingTables.toString();
    }
  }

  void _addBranch() {
    if (!_allowMultipleBranches) return;
    setState(() {
      final branch = Branch(name: '', address: '', isHeadOffice: false);
      _branches.add(branch);
      _registerBranchControllers(branch);
    });
  }

  void _removeBranch(int index) {
    if (!_allowMultipleBranches || _branches.length <= 1) {
      return;
    }
    setState(() {
      final removed = _branches.removeAt(index);
      _disposeBranchControllers(removed);
    });
  }

  void _registerBranchControllers(Branch branch) {
    _nameControllers.putIfAbsent(
      branch.id,
      () => TextEditingController(text: branch.name),
    );
    _addressControllers.putIfAbsent(
      branch.id,
      () => TextEditingController(text: branch.address),
    );
  }

  void _disposeBranchControllers(Branch branch) {
    _nameControllers.remove(branch.id)?.dispose();
    _addressControllers.remove(branch.id)?.dispose();
  }

  TextEditingController _controllerFor(
    Map<String, TextEditingController> cache,
    String key,
    String value,
  ) {
    return cache.putIfAbsent(key, () => TextEditingController(text: value));
  }

  void _updateBranch(int index, String name, String address) {
    setState(() {
      _branches[index] = _branches[index].copyWith(
        name: name,
        address: address,
      );
    });
  }

  void _updateHeadOffice(String name, String address) {
    setState(() {
      _headOffice = Branch(
        id: _headOffice?.id,
        name: name,
        address: address,
        isHeadOffice: true,
      );
    });
  }

  bool _validateForm() {
    if (_allowMultipleBranches) {
      if (_headOffice == null ||
          _headOffice!.name.trim().isEmpty ||
          _headOffice!.address.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please complete head office details'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    }

    if (_branches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one branch'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    for (var branch in _branches) {
      if (branch.name.trim().isEmpty || branch.address.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please complete all branch details'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    }

    return true;
  }

  void _onContinue() {
    if (_validateForm()) {
      final primaryAddress = _allowMultipleBranches
          ? (_headOffice?.address ??
                (_branches.isNotEmpty ? _branches.first.address : ''))
          : (_branches.isNotEmpty ? _branches.first.address : '');

      final updatedData = widget.onboardingData.copyWith(
        addressUrl: primaryAddress,
        totalTables: int.tryParse(_totalTablesController.text.trim()) ?? 0,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              OperationalSetupPage(onboardingData: updatedData),
        ),
      );
    }
  }

  @override
  void dispose() {
    _totalTablesController.dispose();
    for (final controller in _nameControllers.values) {
      controller.dispose();
    }
    for (final controller in _addressControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Sign Up',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          buildStepIndicator(2),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Heading
                  const Text(
                    'Branch Management',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _allowMultipleBranches
                        ? 'Add your head office and branches'
                        : 'Add your branch details',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 32),

                  // Head Office Section (only for multiple branches)
                  if (_allowMultipleBranches) ...[
                    _buildSectionHeader('Head Office', Icons.business),
                    const SizedBox(height: 16),
                    _buildBranchCard(
                      isHeadOffice: true,
                      controllerKey: _headOfficeKey,
                      name: _headOffice?.name ?? '',
                      address: _headOffice?.address ?? '',
                      displayId: _headOffice?.id ?? 'HEAD-OFFICE',
                      onNameChanged: (value) {
                        _updateHeadOffice(value, _headOffice?.address ?? '');
                      },
                      onAddressChanged: (value) {
                        _updateHeadOffice(_headOffice?.name ?? '', value);
                      },
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Branches Section
                  _buildSectionHeader(
                    _allowMultipleBranches ? 'Branches' : 'Branch Details',
                    Icons.store,
                  ),
                  const SizedBox(height: 16),

                  // Branch Cards
                  ..._branches.asMap().entries.map((entry) {
                    int index = entry.key;
                    Branch branch = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildBranchCard(
                        isHeadOffice: false,
                        controllerKey: branch.id,
                        name: branch.name,
                        address: branch.address,
                        displayId: branch.id,
                        branchNumber: _allowMultipleBranches ? index + 1 : null,
                        onNameChanged: (value) {
                          _updateBranch(index, value, branch.address);
                        },
                        onAddressChanged: (value) {
                          _updateBranch(index, branch.name, value);
                        },
                        onRemove: _allowMultipleBranches && _branches.length > 1
                            ? () => _removeBranch(index)
                            : null,
                      ),
                    );
                  }).toList(),

                  // Add Branch Button
                  if (_allowMultipleBranches)
                    OutlinedButton.icon(
                      onPressed: _addBranch,
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text('Add Another Branch'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFC5E03),
                        side: const BorderSide(
                          color: Color(0xFFFC5E03),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                      ),
                    ),

                  const SizedBox(height: 32),

                  // Total Tables
                  _buildSectionHeader('Total Tables', Icons.table_restaurant),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _totalTablesController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                    decoration: InputDecoration(
                      hintText: 'e.g. 20',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                      prefixIcon: Icon(
                        Icons.table_restaurant,
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
                        borderSide: const BorderSide(
                          color: Color(0xFFFC5E03),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Back',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _onContinue,
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
                              Text(
                                'Continue',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFC5E03).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFFFC5E03)),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildBranchCard({
    required bool isHeadOffice,
    required String controllerKey,
    required String name,
    required String address,
    required String displayId,
    int? branchNumber,
    required Function(String) onNameChanged,
    required Function(String) onAddressChanged,
    VoidCallback? onRemove,
  }) {
    final nameController = _controllerFor(
      _nameControllers,
      controllerKey,
      name,
    );
    final addressController = _controllerFor(
      _addressControllers,
      controllerKey,
      address,
    );
    final idPreview = displayId.isEmpty
        ? 'N/A'
        : (displayId.length > 8
              ? displayId.substring(0, 8).toUpperCase()
              : displayId.toUpperCase());

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
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
          // Header with ID and remove button
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFC5E03).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isHeadOffice ? Icons.business : Icons.store,
                      size: 14,
                      color: const Color(0xFFFC5E03),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isHeadOffice
                          ? 'Head Office'
                          : branchNumber != null
                          ? 'Branch $branchNumber'
                          : 'Branch',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFC5E03),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (onRemove != null)
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: Colors.red,
                  tooltip: 'Remove branch',
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Auto-generated ID Display
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.tag, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 8),
                Text(
                  'ID: ',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  idPreview,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '(Auto-generated)',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[400],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Name Field
          _buildLabel('Name'),
          _buildTextField(
            controller: nameController,
            hintText: isHeadOffice
                ? 'e.g. Head Office - Downtown'
                : 'e.g. Branch - Mall Road',
            icon: Icons.business_outlined,
            onChanged: onNameChanged,
          ),
          const SizedBox(height: 16),

          // Address Field with Google Map Icon
          _buildLabel('Address'),
          _buildAddressField(
            controller: addressController,
            onChanged: onAddressChanged,
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
          fontSize: 13,
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
    required Function(String) onChanged,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
        prefixIcon: Icon(icon, size: 18, color: Colors.grey[500]),
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
          borderSide: const BorderSide(color: Color(0xFFFC5E03), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildAddressField({
    required TextEditingController controller,
    required Function(String) onChanged,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      maxLines: 2,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        hintText: 'Enter address or search on map',
        hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
        prefixIcon: Icon(
          Icons.location_on_outlined,
          size: 18,
          color: Colors.grey[500],
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.map, color: Color(0xFFFC5E03)),
          onPressed: () {
            // TODO: Implement Google Maps integration
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Google Maps integration coming soon!'),
                backgroundColor: Color(0xFFFC5E03),
              ),
            );
          },
          tooltip: 'Search on Google Maps',
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
          borderSide: const BorderSide(color: Color(0xFFFC5E03), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    );
  }
}
