import 'dart:convert';
import 'dart:ui'; // For blur effect
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddressDetailsScreen extends StatefulWidget {
  const AddressDetailsScreen({super.key});

  @override
  _AddressDetailsScreenState createState() => _AddressDetailsScreenState();
}

class _AddressDetailsScreenState extends State<AddressDetailsScreen> {
  Map<String, dynamic>? addressData;
  final _formKey = GlobalKey<FormState>();

  // Controllers for primary address
  late TextEditingController _addressController;
  late TextEditingController _address2Controller;
  late TextEditingController _pinCodeController;
  late TextEditingController _countryController;
  late TextEditingController _stateController;
  late TextEditingController _districtController;
  late TextEditingController _cityController;
  late TextEditingController _mandalController;

  // Controllers for alternate address
  late TextEditingController _address1Controller;
  late TextEditingController _address12Controller;
  late TextEditingController _pinCode1Controller;
  late TextEditingController _country1Controller;
  late TextEditingController _state1Controller;
  late TextEditingController _district1Controller;
  late TextEditingController _city1Controller;
  late TextEditingController _mandal1Controller;

  bool _copyAddress = false;
  bool _isEditable = false; // Variable to control edit mode

  // State variables for handling loading and errors
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    fetchAddressDetails();
  }

  // Initialize all controllers
  void _initializeControllers() {
    // Primary Address Controllers
    _addressController = TextEditingController();
    _address2Controller = TextEditingController();
    _pinCodeController = TextEditingController();
    _countryController = TextEditingController();
    _stateController = TextEditingController();
    _districtController = TextEditingController();
    _cityController = TextEditingController();
    _mandalController = TextEditingController();

    // Alternate Address Controllers
    _address1Controller = TextEditingController();
    _address12Controller = TextEditingController();
    _pinCode1Controller = TextEditingController();
    _country1Controller = TextEditingController();
    _state1Controller = TextEditingController();
    _district1Controller = TextEditingController();
    _city1Controller = TextEditingController();
    _mandal1Controller = TextEditingController();
  }

  Future<void> fetchAddressDetails() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String studId = prefs.getString('studId') ?? '';
    String colCode = prefs.getString('colCode') ?? '';
    String collegeId = prefs.getString('collegeId') ?? '';
    String adminUserId = prefs.getString('adminUserId') ?? '';

    final requestBody = {
      "GrpCode": "Beesdev",
      "ColCode": colCode,
      "CollegeId": collegeId,
      "StudentId": studId,
      "AddressId": 0,
      "Address": "",
      "Address2": "",
      "Country": "",
      "Mandal": "",
      "District": "",
      "City": "",
      "State": "",
      "PinCode": "",
      "Address1": "",
      "Address12": "",
      "Country1": "",
      "Mandal1": "",
      "City1": "",
      "District1": "",
      "State1": "",
      "PinCode1": "",
      "LoginIpAddress": "",
      "LoginSystemName": "",
      "UserId": adminUserId,
      "ChangeReason": "",
      "Flag": "VIEW"
    };

    try {
      final response = await http.post(
        Uri.parse(
            'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/StudentAddressSaving'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Fetched Address Data: $data');

        if (data['studentAddressDetailsDisplayList'] != null &&
            data['studentAddressDetailsDisplayList'].isNotEmpty) {
          setState(() {
            addressData = data['studentAddressDetailsDisplayList'].first;
            errorMessage = '';

            // Populate controllers with fetched data
            _addressController.text = addressData?['address'] ?? '';
            _address2Controller.text = addressData?['address2'] ?? '';
            _pinCodeController.text = addressData?['pinCode'] ?? '';
            _countryController.text = addressData?['country'] ?? '';
            _stateController.text = addressData?['state'] ?? '';
            _districtController.text = addressData?['district'] ?? '';
            _cityController.text = addressData?['city'] ?? '';
            _mandalController.text = addressData?['mandal'] ?? '';

            _address1Controller.text = addressData?['address1'] ?? '';
            _address12Controller.text = addressData?['address12'] ?? '';
            _pinCode1Controller.text = addressData?['pinCode1'] ?? '';
            _country1Controller.text = addressData?['country1'] ?? '';
            _state1Controller.text = addressData?['state1'] ?? '';
            _district1Controller.text = addressData?['district1'] ?? '';
            _city1Controller.text = addressData?['city1'] ?? '';
            _mandal1Controller.text = addressData?['mandal1'] ?? '';
          });
        } else {
          // No data available
          setState(() {
            addressData = null;
            errorMessage = 'No Address Details Available.';
          });
        }
      } else {
        // Handle non-200 responses
        setState(() {
          addressData = null;
          errorMessage = 'Failed to load address details.';
        });
        print('Failed to fetch address details: ${response.statusCode}');
      }
    } catch (e) {
      // Handle errors
      setState(() {
        addressData = null;
        errorMessage = 'Error fetching data: $e';
      });
      print('Error fetching address details: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _copyPrimaryToAlternate() {
    if (_copyAddress) {
      _address1Controller.text = _addressController.text;
      _address12Controller.text = _address2Controller.text;
      _pinCode1Controller.text = _pinCodeController.text;
      _country1Controller.text = _countryController.text;
      _state1Controller.text = _stateController.text;
      _district1Controller.text = _districtController.text;
      _city1Controller.text = _cityController.text;
      _mandal1Controller.text = _mandalController.text;
    }
  }

  Future<void> _saveAddressDetails() async {
    if (!_isEditable) return;

    if (!_formKey.currentState!.validate()) {
      // If the form is not valid, do not proceed.
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String studId = prefs.getString('studId') ?? '';
    String colCode = prefs.getString('colCode') ?? '';
    String collegeId = prefs.getString('collegeId') ?? '';
    String adminUserId = prefs.getString('adminUserId') ?? '';

    final updatedData = {
      "GrpCode": "Beesdev",
      "ColCode": colCode,
      "CollegeId": collegeId,
      "StudentId": studId,
      "AddressId": 0,
      "Address": _addressController.text,
      "Address2": _address2Controller.text,
      "Country": _countryController.text,
      "Mandal": _mandalController.text,
      "District": _districtController.text,
      "City": _cityController.text,
      "State": _stateController.text,
      "PinCode": _pinCodeController.text,
      "Address1": _address1Controller.text,
      "Address12": _address12Controller.text,
      "Country1": _country1Controller.text,
      "Mandal1": _mandal1Controller.text,
      "City1": _city1Controller.text,
      "District1": _district1Controller.text,
      "State1": _state1Controller.text,
      "PinCode1": _pinCode1Controller.text,
      "LoginIpAddress": "",
      "LoginSystemName": "",
      "UserId": adminUserId,
      "ChangeReason": "", // You can add a field to capture change reason if needed
      "Flag": "OVERWRITE"
    };

    // Show a loading indicator while saving
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final response = await http.post(
        Uri.parse(
            'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/StudentAddressSaving'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedData),
      );

      Navigator.of(context).pop(); // Remove the loading indicator

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final message = responseBody['message'] ?? 'Address updated successfully';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );

        if (message.toLowerCase().contains('success')) {
          // Reload the data to reflect changes
          fetchAddressDetails();
          setState(() {
            _isEditable = false; // Exit edit mode after successful save
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update address.')),
        );
        print('Failed to update address: ${response.statusCode}');
      }
    } catch (e) {
      Navigator.of(context).pop(); // Remove the loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving address: $e')),
      );
      print('Error saving address details: $e');
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditable = !_isEditable; // Toggle the edit state
      if (!_isEditable) {
        // If exiting edit mode, reload data to discard changes
        fetchAddressDetails();
      }
    });
  }

  @override
  void dispose() {
    // Dispose all controllers to free up resources
    _addressController.dispose();
    _address2Controller.dispose();
    _pinCodeController.dispose();
    _countryController.dispose();
    _stateController.dispose();
    _districtController.dispose();
    _cityController.dispose();
    _mandalController.dispose();

    _address1Controller.dispose();
    _address12Controller.dispose();
    _pinCode1Controller.dispose();
    _country1Controller.dispose();
    _state1Controller.dispose();
    _district1Controller.dispose();
    _city1Controller.dispose();
    _mandal1Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a Stack to place a background gradient and content over it
      body: Stack(
        children: [
          // Background gradient with blue shades
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade900, Colors.blue.shade400],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Main content with SafeArea
          SafeArea(
            child: Column(
              children: [
                // Custom AppBar
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 24.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Address Details',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          _isEditable ? Icons.cancel : Icons.edit,
                          color: Colors.white,
                        ),
                        onPressed: _toggleEditMode,
                      ),
                      if (_isEditable)
                        IconButton(
                          icon: const Icon(Icons.save, color: Colors.white),
                          onPressed: () {
                            _copyPrimaryToAlternate();
                            _saveAddressDetails();
                          },
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: isLoading
                      ? const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : addressData != null
                      ? _buildAddressForms()
                      : Center(
                    child: Text(
                      errorMessage.isNotEmpty
                          ? errorMessage
                          : 'No Address Details Available.',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressForms() {
    return Form(
      key: _formKey,
      child: ListView(
        padding:
        const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 32.0),
        children: [
          _buildAddressCard(
            'Primary Address',
            _addressController,
            _address2Controller,
            _pinCodeController,
            _countryController,
            _stateController,
            _districtController,
            _cityController,
            _mandalController,
            _isEditable,
          ),
          const SizedBox(height: 20),
          _buildCopyAddressCheckbox(),
          const SizedBox(height: 20),
          _buildAddressCard(
            'Alternate Address',
            _address1Controller,
            _address12Controller,
            _pinCode1Controller,
            _country1Controller,
            _state1Controller,
            _district1Controller,
            _city1Controller,
            _mandal1Controller,
            _isEditable,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildCopyAddressCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _copyAddress,
          onChanged: _isEditable
              ? (bool? value) {
            setState(() {
              _copyAddress = value ?? false;
              _copyPrimaryToAlternate();
            });
          }
              : null,
          activeColor: Colors.white,
          checkColor: Colors.blue.shade900,
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'Copy to Alternate Address',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressCard(
      String label,
      TextEditingController addressLine1Controller,
      TextEditingController addressLine2Controller,
      TextEditingController pinCodeController,
      TextEditingController countryController,
      TextEditingController stateController,
      TextEditingController districtController,
      TextEditingController cityController,
      TextEditingController mandalController,
      bool isEditable,
      ) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2), // Darker background for contrast
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Address fields with icons
          _buildTextField(
              Icons.home, 'Address', addressLine1Controller, isEditable),
          _buildTextField(Icons.home_work, 'Address Line 2',
              addressLine2Controller, isEditable),
          _buildTextField(
              Icons.pin_drop, 'Pin Code', pinCodeController, isEditable),
          _buildTextField(
              Icons.flag, 'Country', countryController, isEditable),
          _buildTextField(Icons.map, 'State', stateController, isEditable),
          _buildTextField(
              Icons.location_city, 'District', districtController, isEditable),
          _buildTextField(
              Icons.location_on, 'City', cityController, isEditable),
          _buildTextField(
              Icons.location_searching, 'Mandal', mandalController, isEditable),
        ],
      ),
    );
  }

  Widget _buildTextField(IconData icon, String label,
      TextEditingController controller, bool isEditable) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: controller,
              readOnly: !isEditable,
              enabled: isEditable,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.1), // Slight background color
                contentPadding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                labelText: label,
                labelStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white54),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(8),
                ),
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white54),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (isEditable && (value == null || value.isEmpty)) {
                  return 'Please enter $label';
                }
                return null;
              },
              cursorColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
