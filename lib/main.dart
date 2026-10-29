import 'package:flutter/material.dart';

void main() {
  runApp(const EcoCollectApp());
}

// MAIN APP
class EcoCollectApp extends StatelessWidget {
  const EcoCollectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EcoCollect',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
        ),
      ),
      home: const PickupScreen(),
    );
  }
}

// SCREEN 1: WASTE PICKUP FORM
class PickupScreen extends StatefulWidget {
  const PickupScreen({super.key});

  @override
  State<PickupScreen> createState() => _PickupScreenState();
}

class _PickupScreenState extends State<PickupScreen> {
  // Used to validate all form fields
  final formKey = GlobalKey<FormState>();

  // Controllers store the entered text
  final houseController = TextEditingController();
  final areaController = TextEditingController();
  final cityController = TextEditingController();
  final pinController = TextEditingController();

  // Store the selected options
  String? wasteType;
  String? timeSlot;
  DateTime? pickupDate;

  // Controls the date error message
  bool dateError = false;

  // Waste categories
  final wasteTypes = [
    'Dry Waste',
    'Wet Waste',
    'Plastic Waste',
    'Electronic Waste',
  ];

  // Available pickup times
  final timeSlots = [
    '9 AM - 11 AM',
    '11 AM - 1 PM',
    '2 PM - 4 PM',
    '4 PM - 6 PM',
  ];

  // Reusable text field for address details
  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLength: maxLength,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          counterText: '',
        ),
      ),
    );
  }

  // Validate required text fields
  String? requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  // Open the calendar to select a pickup date
  Future<void> selectDate() async {
    DateTime today = DateTime.now();

    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: pickupDate ?? today,
      firstDate: DateTime(today.year, today.month, today.day),
      lastDate: DateTime(today.year + 1, 12, 31),
    );

    if (selectedDate != null) {
      setState(() {
        pickupDate = selectedDate;
        dateError = false;
      });
    }
  }

  // Validate and submit the form
  void schedulePickup() {
    // Hide the keyboard
    FocusScope.of(context).unfocus();

    // Validate all TextFormField and dropdown fields
    bool formIsValid = formKey.currentState!.validate();

    // Check the date separately
    setState(() {
      dateError = pickupDate == null;
    });

    // Stop if any field is invalid
    if (!formIsValid || pickupDate == null) {
      return;
    }

    // Create the complete address
    String address = '${houseController.text.trim()}, '
        '${areaController.text.trim()}, '
        '${cityController.text.trim()} - '
        '${pinController.text.trim()}';

    // Open the confirmation screen and pass the details
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmationScreen(
          wasteType: wasteType!,
          address: address,
          date: pickupDate!,
          timeSlot: timeSlot!,
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Release controllers when this screen is removed
    houseController.dispose();
    areaController.dispose();
    cityController.dispose();
    pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoCollect ♻️'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      // Makes the form scrollable
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Schedule Waste Pickup',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Help keep our neighbourhood clean!',
                style: TextStyle(fontSize: 15),
              ),

              const SizedBox(height: 25),

              // WASTE CATEGORY
              const Text(
                'Select Waste Type',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: wasteType,
                isExpanded: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Choose waste type',
                ),
                items: wasteTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    wasteType = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a waste type';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 22),

              const Text(
                'Pickup Address',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              // HOUSE AND STREET
              buildTextField(
                controller: houseController,
                label: 'House No. / Street Address',
                validator: requiredValidator,
              ),

              // AREA
              buildTextField(
                controller: areaController,
                label: 'Area / Locality',
                validator: requiredValidator,
              ),

              // CITY
              buildTextField(
                controller: cityController,
                label: 'City',
                validator: requiredValidator,
              ),

              // PIN CODE
              buildTextField(
                controller: pinController,
                label: '6-digit Indian PIN Code',
                keyboardType: TextInputType.number,
                maxLength: 6,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your PIN code';
                  }

                  // First digit must be 1-9,
                  // followed by exactly five digits
                  if (!RegExp(r'^[1-9][0-9]{5}$').hasMatch(value.trim())) {
                    return 'Enter a valid 6-digit PIN code';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 8),

              // PICKUP DATE
              const Text(
                'Pickup Date',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: selectDate,
                  icon: const Icon(Icons.calendar_month),
                  label: Text(
                    pickupDate == null
                        ? 'Choose Pickup Date'
                        : '${pickupDate!.day}/'
                            '${pickupDate!.month}/'
                            '${pickupDate!.year}',
                  ),
                ),
              ),

              // Show date error directly below the button
              if (dateError)
                const Padding(
                  padding: EdgeInsets.only(top: 8, left: 12),
                  child: Text(
                    'Please select a pickup date',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),

              const SizedBox(height: 22),

              // PICKUP TIME
              const Text(
                'Preferred Time Slot',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: timeSlot,
                isExpanded: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Choose time slot',
                ),
                items: timeSlots.map((slot) {
                  return DropdownMenuItem(
                    value: slot,
                    child: Text(slot),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    timeSlot = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a time slot';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),

              // SUBMIT BUTTON
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: schedulePickup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Confirm Pickup',
                    style: TextStyle(fontSize: 17),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Center(
                child: Text(
                  'Reduce • Reuse • Recycle 🌱',
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// SCREEN 2: PICKUP CONFIRMATION
class ConfirmationScreen extends StatefulWidget {
  final String wasteType;
  final String address;
  final DateTime date;
  final String timeSlot;

  const ConfirmationScreen({
    super.key,
    required this.wasteType,
    required this.address,
    required this.date,
    required this.timeSlot,
  });

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  @override
  void initState() {
    super.initState();

    // Display the success SnackBar after the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pickup scheduled successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pickup Confirmation'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 95,
              ),

              const SizedBox(height: 18),

              const Text(
                'Pickup Confirmed!',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Your waste pickup request has been submitted.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 28),

              // Show the details entered in the form
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pickup Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 28),
                      Text('Waste Type: ${widget.wasteType}'),
                      const SizedBox(height: 14),
                      Text('Address: ${widget.address}'),
                      const SizedBox(height: 14),
                      Text(
                        'Date: ${widget.date.day}/'
                        '${widget.date.month}/'
                        '${widget.date.year}',
                      ),
                      const SizedBox(height: 14),
                      Text('Time: ${widget.timeSlot}'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Open a fresh form for another pickup
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PickupScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Schedule Another Pickup'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
