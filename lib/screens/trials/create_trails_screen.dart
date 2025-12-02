
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/utils/colors.dart';
import 'package:hilite/utils/dimensions.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/trial_controller.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/snackbars.dart';


class CreateTrialScreen extends StatefulWidget {
  const CreateTrialScreen({super.key});

  @override
  State<CreateTrialScreen> createState() => _CreateTrialScreenState();
}


class _CreateTrialScreenState extends State<CreateTrialScreen> {
  final TrialController controller = Get.find<TrialController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _feeController = TextEditingController();
  final _ageGroupController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  String _trialType = 'open';
  XFile? _bannerFile;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _feeController.dispose();
    _ageGroupController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // --- Helper Functions ---

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required.';
    }
    return null;
  }

  String? _feeValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Registration fee is required.';
    }
    final fee = double.tryParse(value);
    if (fee == null || fee < 0) {
      return 'Please enter a valid non-negative number.';
    }
    return null;
  }

  Future<void> _pickBanner() async {
    final ImagePicker picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    setState(() => _bannerFile = file);
  }

  Future<void> _submitTrial() async {
    // Check form field validation AND selected date
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      final success = await controller.createTrial(
        name: _nameController.text.trim(),
        location: _locationController.text.trim(),
        date: _selectedDate!,
        ageGroup: _ageGroupController.text.trim(),
        registrationFee: double.tryParse(_feeController.text.trim()) ?? 0.0,
        type: _trialType,
        description: _descriptionController.text.trim(),
        banner: _bannerFile,
      );
      if (success) {
        Get.back();
      }
    } else if (_selectedDate == null) {
      // Show snackbar or alert if date is missing
      // CustomSnackBar.failure(message: 'Please select a trial date.');
      Get.snackbar('Error', 'Please select a trial date.', snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Trial')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Banner Picker (No change)
              GestureDetector(
                onTap: _pickBanner,
                child: Container(
                  height: 150,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _bannerFile == null
                      ? const Text('Tap to add Banner Image (Optional)', style: TextStyle(color: Colors.white70))
                      : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(File(_bannerFile!.path), fit: BoxFit.cover)
                  ),
                ),
              ),
               SizedBox(height: Dimensions.height20),

              // Form Fields with custom validators
              CustomTextField(
                controller: _nameController,
                hintText: 'Trial Name *',
                validator: _requiredValidator, // ⬅️ Using internal function
              ),
              SizedBox(height: Dimensions.height20),

              CustomTextField(
                controller: _locationController,
                hintText: 'Location *',
                validator: _requiredValidator, // ⬅️ Using internal function
              ),
              SizedBox(height: Dimensions.height20),

              CustomTextField(
                controller: _ageGroupController,
                hintText: 'Age Group (e.g., U-18) *',
                validator: _requiredValidator, // ⬅️ Using internal function
              ),
              SizedBox(height: Dimensions.height20),

              CustomTextField(
                controller: _feeController,
                hintText: 'Registration Fee *',
                keyboardType: TextInputType.number,
                validator: _feeValidator, // ⬅️ Using internal function for number validation
              ),
              SizedBox(height: Dimensions.height20),

              CustomTextField(controller: _descriptionController, hintText: 'Description', maxLines: 3),
              SizedBox(height: Dimensions.height20),


              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black87.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(Dimensions.radius15)
                ),
                child: ListTile(
                  title: Text(_selectedDate == null ? 'Select Date *' : 'Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) setState(() => _selectedDate = picked);
                  },
                ),
              ),

              // Trial Type Dropdown
              DropdownButtonFormField<String>(
                value: _trialType,
                decoration: const InputDecoration(labelText: 'Trial Type *'),
                items: const [
                  DropdownMenuItem(value: 'open', child: Text('Open (Public)')),
                  DropdownMenuItem(value: 'invite_only', child: Text('Invite Only')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _trialType = value);
                },
                validator: _requiredValidator, // Ensure a type is selected (though dropdown usually guarantees this)
              ),
              const SizedBox(height: 30),

              // Submit Button
              Obx(() => CustomButton(
                text: 'Create Trial Event',
                onPressed: controller.isProcessing.value ? null : _submitTrial,
                isLoading: controller.isProcessing.value,
              )),
            ],
          ),
        ),
      ),
    );
  }
}