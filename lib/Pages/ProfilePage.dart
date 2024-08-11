import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/services.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _cigarettePackAmountController = TextEditingController();
  final TextEditingController _cigarettePriceController = TextEditingController();
  final TextEditingController _pastSmokingTimeController = TextEditingController();
  final TextEditingController _dailyCigaretteNumberController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late Box _box;
  bool _isFirstTime = true;

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    _box = await Hive.openBox('cigarette_tracker');

    // Check if this is the first time the app is opened
    if (_box.isEmpty) {
      _isFirstTime = true;
    } else {
      _isFirstTime = false;
      // Retrieve saved data from Hive and set it to the controllers
      _cigarettePackAmountController.text = _box.get('cigarette_pack_amount', defaultValue: '20').toString();
      _cigarettePriceController.text = _box.get('cigarette_price', defaultValue: '0.0').toString();
      _pastSmokingTimeController.text = _box.get('past_smoking_time', defaultValue: '0').toString();
      _dailyCigaretteNumberController.text = _box.get('daily_cigarette_number', defaultValue: '0').toString();
    }

    setState(() {}); // Update the UI
  }

  void _saveData() {
    if (_formKey.currentState!.validate()) {
      int cigarettePackAmount = int.parse(_cigarettePackAmountController.text);
      double cigarettePrice = double.parse(_cigarettePriceController.text);
      int pastSmokingTime = int.parse(_pastSmokingTimeController.text);
      int dailyCigaretteNumber = int.parse(_dailyCigaretteNumberController.text);
      DateTime quitDate = DateTime.now();

      _box.put('cigarette_pack_amount', cigarettePackAmount);
      _box.put('cigarette_price', cigarettePrice);
      _box.put('past_smoking_time', pastSmokingTime);
      _box.put('daily_cigarette_number', dailyCigaretteNumber);
      if (_box.get('_quitdate') == null) {
        _box.put('_quitdate', quitDate);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data saved successfully')),
      );

      // Navigate to HomePage ("/") if this is the first time
      if (_isFirstTime) {
        Navigator.pushReplacementNamed(context, '/');
      }
    }
  }

  void _retrieveData() {
    int? cigarettePackAmount = _box.get('cigarette_pack_amount');
    double? cigarettePrice = _box.get('cigarette_price');
    int? pastSmokingTime = _box.get('past_smoking_time');
    int? dailyCigaretteNumber = _box.get('daily_cigarette_number');

    if (cigarettePackAmount != null && cigarettePrice != null && pastSmokingTime != null && dailyCigaretteNumber != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cigarette Pack Amount: $cigarettePackAmount, Cigarette Price: $cigarettePrice, Past Smoking Time: $pastSmokingTime, Daily Cigarette Number: $dailyCigaretteNumber')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No data found')),
      );
    }
  }

  String? _validateField(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field cannot be empty';
    }
    if(double.parse(value) == 0)
      return 'This field cannot be 0';
    return null;
  }

  @override
  void dispose() {
    _cigarettePackAmountController.dispose();
    _cigarettePriceController.dispose();
    _pastSmokingTimeController.dispose();
    _dailyCigaretteNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green, // Set the background color to green
        title: Text('Profile Page'),
        centerTitle: true,
        automaticallyImplyLeading: !_isFirstTime, // Hide back arrow if it's the first time
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _cigarettePackAmountController,
                  decoration: InputDecoration(labelText: 'Bir pakette kaç adet sigara var ?'),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: _validateField,
                ),
                SizedBox(height: 30),
                TextFormField(
                  controller: _cigarettePriceController,
                  decoration: InputDecoration(labelText: 'Bir paket sigaranın fiyatı nedir ?'),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: _validateField,
                ),
                SizedBox(height: 30),
                TextFormField(
                  controller: _pastSmokingTimeController,
                  decoration: InputDecoration(labelText: 'Kaç yıldır sigara içiyorsunuz ?'),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: _validateField,
                ),
                SizedBox(height: 30),
                TextFormField(
                  controller: _dailyCigaretteNumberController,
                  decoration: InputDecoration(labelText: 'Günde kaç adet sigara içiyorsun ?'),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: _validateField,
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _saveData,
                  child: Text('Save'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _retrieveData,
                  child: Text('Retrieve Data'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
