

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/controllers/auth_controller.dart';
import 'package:hilite/controllers/user_controller.dart';
import 'package:hilite/widgets/custom_appbar.dart';
import 'package:hilite/widgets/custom_button.dart';
import 'package:hilite/widgets/custom_textfield.dart';
import 'package:hilite/widgets/country_state_dropdown.dart';
import 'package:hilite/utils/colors.dart';
import 'package:hilite/utils/dimensions.dart';

import '../../widgets/snackbars.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final formKey = GlobalKey<FormState>();
  final UserController userController = Get.find<UserController>();
  final AuthController authController = Get.find<AuthController>();

  // Common
  late TextEditingController nameController;
  late TextEditingController usernameController;
  late TextEditingController numberController;
  late TextEditingController bioController;

  // Location State
  String? selectedCountry;
  String? selectedState;

  // Player
  List<String> selectedPositions = []; // Holds the full display strings
  late TextEditingController preferredFootController;
  late TextEditingController currentClubController;
  late TextEditingController heightController;
  late TextEditingController weightController;

  // Agent
  late TextEditingController agencyNameController;
  late TextEditingController registrationIdController;
  late TextEditingController experienceController;

  // Club
  late TextEditingController clubNameController;
  late TextEditingController managerController;
  late TextEditingController clubTypeController;
  late TextEditingController yearFoundedController;

  final List<String> positions = [
    "GK — Goalkeeper",
    "CB — Center Back",
    "SW — Sweeper",
    "RB — Right Back",
    "LB — Left Back",
    "RWB — Right Wing Back",
    "LWB — Left Wing Back",
    "CDM — Defensive Midfielder",
    "CM — Central Midfielder",
    "CAM — Attacking Midfielder",
    "RM — Right Midfielder",
    "LM — Left Midfielder",
    "RW — Right Winger",
    "LW — Left Winger",
    "CF — Center Forward",
    "ST — Striker",
    "SS — Second Striker",
    "WF — Wide Forward",
    "IF — Inside Forward",
    "WB — Wing Back",
    "MF — Midfielder",
    "DF — Defender",
    "FW — Forward",
    "RF — Right Forward",
    "LF — Left Forward",
  ];

  final List<String> feet = ['Left', 'Right', 'Both'];
  final List<String> clubTypes = ['Academy', 'Amateur', 'Professional'];

  @override
  void initState() {
    super.initState();
    final user = userController.user.value;

    nameController = TextEditingController(text: user?.name ?? '');
    usernameController = TextEditingController(text: user?.username ?? '');
    numberController = TextEditingController(text: user?.number ?? '');
    bioController = TextEditingController(text: user?.bio ?? '');

    selectedCountry = user?.country;
    selectedState = user?.state;

    // --- REVERSE MAP POSITIONS ---
    // Backend returns "GK, ST". We map it back to ["GK — Goalkeeper", "ST — Striker"] for the UI.
    String rawPos = user?.playerDetails?.position ?? '';
    if (rawPos.isNotEmpty) {
      List<String> savedAbbrs = rawPos.split(',').map((e) => e.trim()).toList();
      selectedPositions =
          positions.where((p) {
            String abbr = p.split('—')[0].trim();
            return savedAbbrs.contains(abbr);
          }).toList();
    }

    preferredFootController = TextEditingController(
      text: user?.playerDetails?.preferredFoot ?? '',
    );
    currentClubController = TextEditingController(
      text: user?.playerDetails?.currentClub ?? '',
    );
    heightController = TextEditingController(
      text: user?.playerDetails?.height?.toString() ?? '',
    );
    weightController = TextEditingController(
      text: user?.playerDetails?.weight?.toString() ?? '',
    );

    agencyNameController = TextEditingController(
      text: user?.agentDetails?.agencyName ?? '',
    );
    registrationIdController = TextEditingController(
      text: user?.agentDetails?.registrationId ?? '',
    );
    experienceController = TextEditingController(
      text: user?.agentDetails?.experience ?? '',
    );

    clubNameController = TextEditingController(
      text: user?.clubDetails?.clubName ?? '',
    );
    managerController = TextEditingController(
      text: user?.clubDetails?.manager ?? '',
    );
    clubTypeController = TextEditingController(
      text: user?.clubDetails?.clubType ?? '',
    );
    yearFoundedController = TextEditingController(
      text: user?.clubDetails?.yearFounded ?? '',
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    numberController.dispose();
    bioController.dispose();
    preferredFootController.dispose();
    currentClubController.dispose();
    heightController.dispose();
    weightController.dispose();
    agencyNameController.dispose();
    registrationIdController.dispose();
    experienceController.dispose();
    clubNameController.dispose();
    managerController.dispose();
    clubTypeController.dispose();
    yearFoundedController.dispose();
    super.dispose();
  }






  Map<String, dynamic> _buildBody() {
    final user = userController.user.value;
    if (user == null) return {};

    final Map<String, dynamic> data = {};

    void addIfChanged(String key, dynamic newValue, dynamic oldValue) {
      if (newValue == null) return;

      // If it's a string, trim it for safe comparison
      if (newValue is String) {
        final cleanNew = newValue.trim();
        final cleanOld = oldValue?.toString().trim() ?? '';

        if (cleanNew.isNotEmpty && cleanNew != cleanOld) {
          data[key] = cleanNew;
        }
      } else if (newValue != oldValue) {
        data[key] = newValue;
      }
    }

    // Common
    addIfChanged('name', nameController.text, user.name);
    addIfChanged('username', usernameController.text, user.username);
    addIfChanged('number', numberController.text, user.number);
    addIfChanged('bio', bioController.text, user.bio);

    // --- LOCATION FIX ---
    addIfChanged('country', selectedCountry, user.country);
    addIfChanged('state', selectedState, user.state);

    // Player
    if (user.role == 'player') {
      List<String> abbrs =
          selectedPositions.map((p) => p.split('—')[0].trim()).toList();
      String finalPositions = abbrs.join(', '); // "GK, ST"

      addIfChanged('position', finalPositions, user.playerDetails?.position);
      addIfChanged(
        'currentClub',
        currentClubController.text,
        user.playerDetails?.currentClub,
      );
      addIfChanged(
        'preferredFoot',
        preferredFootController.text,
        user.playerDetails?.preferredFoot,
      );

      final int? h = int.tryParse(
        heightController.text.replaceAll(RegExp(r'[^0-9]'), ''),
      );
      final int? w = int.tryParse(
        weightController.text.replaceAll(RegExp(r'[^0-9]'), ''),
      );
      addIfChanged('height', h, user.playerDetails?.height);
      addIfChanged('weight', w, user.playerDetails?.weight);
    }

    // Agent
    if (user.role == 'agent') {
      addIfChanged(
        'agencyName',
        agencyNameController.text,
        user.agentDetails?.agencyName,
      );
      addIfChanged(
        'registrationId',
        registrationIdController.text,
        user.agentDetails?.registrationId,
      );
      addIfChanged(
        'experience',
        experienceController.text,
        user.agentDetails?.experience,
      );
    }

    // Club
    if (user.role == 'club') {
      addIfChanged(
        'clubName',
        clubNameController.text,
        user.clubDetails?.clubName,
      );
      addIfChanged(
        'manager',
        managerController.text,
        user.clubDetails?.manager,
      );
      addIfChanged(
        'clubType',
        clubTypeController.text,
        user.clubDetails?.clubType,
      );
      addIfChanged(
        'yearFounded',
        yearFoundedController.text,
        user.clubDetails?.yearFounded,
      );
    }

    // DEBUG PRINT TO VERIFY
    debugPrint("🚀 PAYLOAD BEING SENT TO BACKEND: $data");

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030A1B),
      appBar: CustomAppbar(
        backgroundColor: const Color(0xFF030A1B),
        title: 'Edit Profile',
        leadingIcon: const BackButton(color: Colors.white),
      ),
      body: Obx(() {
        final user = userController.user.value;
        if (user == null) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.blueAccent),
          );
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader("Basic Information"),
                CustomTextField(
                  labelText: 'Full name',
                  controller: nameController,
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  labelText: 'Username',
                  controller: usernameController,
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  labelText: 'Bio',
                  controller: bioController,
                  maxLines: 3,
                ),

                const SizedBox(height: 25),
                //
                _buildSectionHeader("Location"),
                // --- COUNTRY STATE WIDGET INJECTED HERE ---
                CountryState(
                  selectedCountry: selectedCountry,
                  selectedState: selectedState,
                  onCountryChanged: (c) => setState(() => selectedCountry = c),
                  onStateChanged: (s) => setState(() => selectedState = s),
                ),
                const SizedBox(height: 20),

                Divider(color: Colors.white.withOpacity(0.1), thickness: 1),
                const SizedBox(height: 20),

                // --- PLAYER DETAILS ---
                if (user.role == 'player') ...[
                  _buildSectionHeader("Player Details"),

                  // MULTI-SELECT POSITIONS
                  GestureDetector(
                    onTap: _showMultiPositionPicker,
                    child: _buildPickerContainer(
                      title: 'Position(s)',
                      value:
                          selectedPositions.isEmpty
                              ? ''
                              : selectedPositions
                                  .map((p) => p.split('—')[0].trim())
                                  .join(', '),
                    ),
                  ),
                  const SizedBox(height: 15),

                  CustomTextField(
                    labelText: 'Current club (Optional)',
                    controller: currentClubController,
                  ),
                  const SizedBox(height: 15),

                  GestureDetector(
                    onTap:
                        () => _showSinglePicker(
                          title: 'Preferred foot',
                          currentValue: preferredFootController.text,
                          options: feet,
                          onSelected:
                              (v) => setState(
                                () => preferredFootController.text = v,
                              ),
                        ),
                    child: _buildPickerContainer(
                      title: 'Preferred foot',
                      value: preferredFootController.text.capitalizeFirst ?? '',
                    ),
                  ),
                  const SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          labelText: 'Height (cm)',
                          controller: heightController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: CustomTextField(
                          labelText: 'Weight (kg)',
                          controller: weightController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],

                // --- AGENT DETAILS ---
                if (user.role == 'agent') ...[
                  _buildSectionHeader("Agent Details"),
                  CustomTextField(
                    labelText: 'Agency name',
                    controller: agencyNameController,
                  ),
                  const SizedBox(height: 15),
                  CustomTextField(
                    labelText: 'Registration ID',
                    controller: registrationIdController,
                  ),
                  const SizedBox(height: 15),
                  CustomTextField(
                    labelText: 'Experience / Summary',
                    controller: experienceController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 30),
                ],

                // --- CLUB DETAILS ---
                if (user.role == 'club') ...[
                  _buildSectionHeader("Club Details"),
                  CustomTextField(
                    labelText: 'Club name',
                    controller: clubNameController,
                  ),
                  const SizedBox(height: 15),
                  CustomTextField(
                    labelText: 'Manager',
                    controller: managerController,
                  ),
                  const SizedBox(height: 15),
                  GestureDetector(
                    onTap:
                        () => _showSinglePicker(
                          title: 'Club type',
                          currentValue: clubTypeController.text,
                          options: clubTypes,
                          onSelected:
                              (v) =>
                                  setState(() => clubTypeController.text = v),
                        ),
                    child: _buildPickerContainer(
                      title: 'Club type',
                      value: clubTypeController.text,
                    ),
                  ),
                  const SizedBox(height: 15),
                  CustomTextField(
                    labelText: 'Year founded',
                    controller: yearFoundedController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 30),
                ],

                // --- SAVE BUTTON ---
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        final body = _buildBody();
                        if (body.isEmpty) {
                          Get.back();
                          CustomSnackBar.showToast(
                            message: 'No changes to save',
                          );
                          return;
                        }
                        authController.updateUserProfile(body);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ===========================================================================
  // UI HELPERS & BOTTOM SHEETS
  // ===========================================================================

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildPickerContainer({required String title, required String value}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              value.isEmpty ? title : value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color:
                    value.isEmpty
                        ? Colors.white.withOpacity(0.4)
                        : Colors.white,
                fontSize: 15,
              ),
            ),
          ),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.white.withOpacity(0.5),
          ),
        ],
      ),
    );
  }

  // --- MULTI-SELECT POSITIONS BOTTOM SHEET ---
  void _showMultiPositionPicker() {
    FocusScope.of(context).unfocus();
    List<String> tempSelected = List.from(selectedPositions);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Color(0xFF1F2937),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Select Positions",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(
                              () => selectedPositions = List.from(tempSelected),
                            );
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Done",
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: positions.length,
                      itemBuilder: (context, index) {
                        final pos = positions[index];
                        final isSelected = tempSelected.contains(pos);
                        return ListTile(
                          onTap: () {
                            setModalState(() {
                              isSelected
                                  ? tempSelected.remove(pos)
                                  : tempSelected.add(pos);
                            });
                          },
                          leading: Icon(
                            isSelected
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            color:
                                isSelected
                                    ? Colors.blueAccent
                                    : Colors.white.withOpacity(0.4),
                          ),
                          title: Text(
                            pos,
                            style: TextStyle(
                              color:
                                  isSelected
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.7),
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- SINGLE SELECT BOTTOM SHEET (Feet, Club Types) ---
  void _showSinglePicker({
    required String title,
    required String currentValue,
    required List<String> options,
    required Function(String) onSelected,
  }) {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F2937),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (context) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  ...options.map((opt) {
                    bool isSelected =
                        currentValue.toLowerCase() == opt.toLowerCase();
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      title: Text(
                        opt,
                        style: TextStyle(
                          color: isSelected ? Colors.blueAccent : Colors.white,
                          fontSize: 16,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      trailing:
                          isSelected
                              ? const Icon(
                                Icons.check_circle_rounded,
                                color: Colors.blueAccent,
                              )
                              : null,
                      onTap: () {
                        onSelected(opt);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
    );
  }
}
