import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddressDetailsScreen extends StatefulWidget {
  const AddressDetailsScreen({super.key});

  @override
  _AddressDetailsScreenState createState() => _AddressDetailsScreenState();
}

class _AddressDetailsScreenState extends State<AddressDetailsScreen> {
  Map<String, dynamic>? addressData;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _addressController;
  late TextEditingController _address2Controller;
  late TextEditingController _pinCodeController;
  late TextEditingController _countryController;
  late TextEditingController _stateController;
  late TextEditingController _districtController;
  late TextEditingController _cityController;
  late TextEditingController _mandalController;
  late TextEditingController _address1Controller;
  late TextEditingController _address12Controller;
  late TextEditingController _pinCode1Controller;
  late TextEditingController _country1Controller;
  late TextEditingController _state1Controller;
  late TextEditingController _district1Controller;
  late TextEditingController _city1Controller;
  late TextEditingController _mandal1Controller;
  bool _copyAddress = false;

  @override
  void initState() {
    super.initState();
    fetchAddressDetails();
  }

  Future<void> fetchAddressDetails() async {
    final response = await http.post(
      Uri.parse('https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/StudentAddressSaving'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "GrpCode": "Bees",
        "ColCode": "0001",
        "CollegeId": "1",
        "StudentId": "1645",
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
        "UserId": 0,
        "ChangeReason": "",
        "Flag": "VIEW"
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        addressData = json.decode(response.body)['studentAddressDetailsDisplayList']?.first;
        _initializeControllers();
      });
    } else {
      // Handle error
      print('Failed to fetch data');
    }
  }

  void _initializeControllers() {
    _addressController = TextEditingController(text: addressData!['address']);
    _address2Controller = TextEditingController(text: addressData!['address2']);
    _pinCodeController = TextEditingController(text: addressData!['pinCode']);
    _countryController = TextEditingController(text: addressData!['country']);
    _stateController = TextEditingController(text: addressData!['state']);
    _districtController = TextEditingController(text: addressData!['district']);
    _cityController = TextEditingController(text: addressData!['city']);
    _mandalController = TextEditingController(text: addressData!['mandal']);
    _address1Controller = TextEditingController(text: addressData!['address1']);
    _address12Controller = TextEditingController(text: addressData!['address12']);
    _pinCode1Controller = TextEditingController(text: addressData!['pinCode1']);
    _country1Controller = TextEditingController(text: addressData!['country1']);
    _state1Controller = TextEditingController(text: addressData!['state1']);
    _district1Controller = TextEditingController(text: addressData!['district1']);
    _city1Controller = TextEditingController(text: addressData!['city1']);
    _mandal1Controller = TextEditingController(text: addressData!['mandal1']);
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
    final updatedData = {
      "GrpCode": "Bees",
      "ColCode": "0001",
      "CollegeId": "1",
      "StudentId": "1645",
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
      "UserId": 0,
      "ChangeReason": "",
      "Flag": "OVERWRITE"
    };

    final response = await http.post(
      Uri.parse('https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/StudentAddressSaving'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updatedData),
    );

    if (response.statusCode == 200) {
      print(response.body.toString());
      final responseBody = json.decode(response.body);
      final message = responseBody['message'] ?? 'Address updated successfully';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      print('Address updated successfully');
    } else {
      print('Failed to update address');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 70.0),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('Address Details', style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.save,color: Colors.blue,),
              onPressed: () {
                _copyPrimaryToAlternate();
                _saveAddressDetails();
              },
            ),
          ],
        ),
        body: addressData == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildAddressForm(
                    'Primary Address',
                    _addressController,
                    _address2Controller,
                    _pinCodeController,
                    _countryController,
                    _stateController,
                    _districtController,
                    _cityController,
                    _mandalController,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: _copyAddress,
                        onChanged: (bool? value) {
                          setState(() {
                            _copyAddress = value ?? false;
                            _copyPrimaryToAlternate();
                          });
                        },
                      ),
                      const Text('Copy to Alternate Address'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildAddressForm(
                    'Alternate Address',
                    _address1Controller,
                    _address12Controller,
                    _pinCode1Controller,
                    _country1Controller,
                    _state1Controller,
                    _district1Controller,
                    _city1Controller,
                    _mandal1Controller,
                  ),
                  const SizedBox(height: 32), // Extra space to ensure scrolling
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressForm(
      String label,
      TextEditingController addressLine1Controller,
      TextEditingController addressLine2Controller,
      TextEditingController pinCodeController,
      TextEditingController countryController,
      TextEditingController stateController,
      TextEditingController districtController,
      TextEditingController cityController,
      TextEditingController mandalController,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.blue
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: addressLine1Controller,
            decoration: const InputDecoration(labelText: 'Address Line 1'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: addressLine2Controller,
            decoration: const InputDecoration(labelText: 'Address Line 2'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: pinCodeController,
            decoration: const InputDecoration(labelText: 'Pin Code'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: countryController,
            decoration: const InputDecoration(labelText: 'Country'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: stateController,
            decoration: const InputDecoration(labelText: 'State'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: districtController,
            decoration: const InputDecoration(labelText: 'District'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: cityController,
            decoration: const InputDecoration(labelText: 'City'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: mandalController,
            decoration: const InputDecoration(labelText: 'Mandal'),
          ),
        ],
      ),
    );
  }
}
