import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hilite/utils/colors.dart';
import 'package:hilite/utils/dimensions.dart';


class CountryService {
  static final CountryService _instance = CountryService._internal();
  factory CountryService() => _instance;
  CountryService._internal();

  List<CountryData>? _cachedCountries;
  Future<List<CountryData>>? _loadingFuture;

  Future<List<CountryData>> loadCountries() async {
    if (_cachedCountries != null) return _cachedCountries!;
    if (_loadingFuture != null) return _loadingFuture!;

    _loadingFuture = _loadCountriesFromAsset();
    _cachedCountries = await _loadingFuture!;
    _loadingFuture = null;

    return _cachedCountries!;
  }

  Future<List<CountryData>> _loadCountriesFromAsset() async {
    final jsonStr = await rootBundle.loadString('assets/countries_state.json');
    final List<dynamic> data = json.decode(jsonStr);
    return data.map((e) => CountryData.fromJson(e)).toList();
  }

  List<CountryData>? getCachedCountries() => _cachedCountries;
  bool get isLoaded => _cachedCountries != null;
  Future<void> preload() async => await loadCountries();
  void clearCache() => _cachedCountries = null;
}

class CountryData {
  final String name;
  final List<StateData> states;
  CountryData({required this.name, required this.states});
  factory CountryData.fromJson(Map<String, dynamic> json) {
    return CountryData(
      name: json['name'] as String,
      states: (json['states'] as List<dynamic>)
          .map((e) => StateData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class StateData {
  final String name;
  StateData({required this.name});
  factory StateData.fromJson(Map<String, dynamic> json) {
    return StateData(name: json['name'] as String);
  }
}




class SearchableBottomSheet extends StatefulWidget {
  final String title;
  final List<String> items;
  final Function(String) onSelect;

  const SearchableBottomSheet({
    super.key,
    required this.title,
    required this.items,
    required this.onSelect,
  });

  @override
  State<SearchableBottomSheet> createState() => _SearchableBottomSheetState();
}

class _SearchableBottomSheetState extends State<SearchableBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items
            .where((item) => item.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75, // Takes up 75% of screen
      decoration: const BoxDecoration(
        color: Color(0xFF1F2937), // Dark Surface Color
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
      child: Column(
        children: [
          // Drag Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 15),

          // Search Bar
          TextField(
            controller: _searchController,
            onChanged: _filterItems,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Search...",
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
              prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.5)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 15),

          // List
          Expanded(
            child: _filteredItems.isEmpty
                ? Center(
              child: Text(
                "No results found",
                style: TextStyle(color: Colors.white.withOpacity(0.5)),
              ),
            )
                : ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: _filteredItems.length,
              separatorBuilder: (context, index) => Divider(
                color: Colors.white.withOpacity(0.05),
                height: 1,
              ),
              itemBuilder: (context, index) {
                final item = _filteredItems[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    item,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: Colors.white.withOpacity(0.2),
                    size: 20,
                  ),
                  onTap: () {
                    widget.onSelect(item);
                    Navigator.pop(context);                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


// ==========================================
// 3. UI: COUNTRY & STATE COMBINED WIDGET
// ==========================================

class CountryState extends StatefulWidget {
  final String? selectedCountry;
  final String? selectedState;
  final Function(String?) onCountryChanged;
  final Function(String?) onStateChanged;

  const CountryState({
    super.key,
    required this.selectedCountry,
    required this.selectedState,
    required this.onCountryChanged,
    required this.onStateChanged,
  });

  @override
  State<CountryState> createState() => _CountryStateState();
}

class _CountryStateState extends State<CountryState> {
  final _countryService = CountryService();
  late final Future<List<CountryData>> _countriesFuture;

  @override
  void initState() {
    super.initState();
    _countriesFuture = _countryService.loadCountries();
  }

  void _openSelectionSheet(String title, List<String> items, Function(String) onSelect) {
    Get.bottomSheet(
      SearchableBottomSheet(
        title: title,
        items: items,
        onSelect: onSelect,
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CountryData>>(
      future: _countriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SizedBox(
              height: 20, width: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blueAccent),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("No countries available", style: TextStyle(color: Colors.white.withOpacity(0.5))));
        }

        final countries = snapshot.data!;
        final countryNames = countries.map((c) => c.name).toList();

        final selectedCountryObj = widget.selectedCountry != null
            ? countries.firstWhere((c) => c.name == widget.selectedCountry, orElse: () => countries.first)
            : null;

        final stateNames = selectedCountryObj?.states.map((s) => s.name).toList() ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- COUNTRY SELECTOR ---
            _buildSelectorField(
              hint: "Choose a country",
              value: widget.selectedCountry,
              onTap: () {
                _openSelectionSheet("Select Country", countryNames, (selected) {
                  widget.onCountryChanged(selected);
                  widget.onStateChanged(null); // Reset state when country changes
                });
              },
            ),

            const SizedBox(height: 20),

            // --- STATE SELECTOR ---
            _buildSelectorField(
              hint: "Choose a state",
              value: widget.selectedState,
              onTap: () {
                if (widget.selectedCountry == null) {
                  Get.snackbar('Hold on', 'Please select a country first',
                      backgroundColor: const Color(0xFF1F2937), colorText: Colors.white);
                  return;
                }
                if (stateNames.isEmpty) {
                  Get.snackbar('Info', 'No states available for this country',
                      backgroundColor: const Color(0xFF1F2937), colorText: Colors.white);
                  return;
                }
                _openSelectionSheet("Select State", stateNames, (selected) {
                  widget.onStateChanged(selected);
                });
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSelectorField({required String hint, required String? value, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.textColor.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value ?? hint,
              style: TextStyle(
                color: value == null ? Colors.white.withOpacity(0.4) : Colors.white,
                fontSize: Dimensions.font17,
                fontFamily: 'Poppins',
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }
}



class CountryDropdown extends StatefulWidget {
  final String? selectedCountry;
  final ValueChanged<String?> onCountryChanged;

  const CountryDropdown({
    Key? key,
    this.selectedCountry,
    required this.onCountryChanged,
  }) : super(key: key);

  @override
  State<CountryDropdown> createState() => _CountryDropdownState();
}

class _CountryDropdownState extends State<CountryDropdown> {
  final _countryService = CountryService();
  late Future<List<String>> _countriesFuture;

  @override
  void initState() {
    super.initState();
    _countriesFuture = _loadCountryNames();
  }

  Future<List<String>> _loadCountryNames() async {
    final countries = await _countryService.loadCountries();
    return countries.map((c) => c.name).toList();
  }

  void _openSelectionSheet(List<String> items) {
    Get.bottomSheet(
      SearchableBottomSheet(
        title: "Select Country",
        items: items,
        onSelect: widget.onCountryChanged,
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _countriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SizedBox(
              height: 20, width: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blueAccent),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("No countries available", style: TextStyle(color: Colors.white.withOpacity(0.5))));
        }

        final countries = snapshot.data!;

        return InkWell(
          onTap: () => _openSelectionSheet(countries),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.selectedCountry ?? "Choose a country",
                  style: TextStyle(
                    color: widget.selectedCountry == null ? Colors.white.withOpacity(0.4) : Colors.white,
                    fontSize: 15,
                    fontFamily: 'Poppins',
                  ),
                ),
                Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white.withOpacity(0.5)),
              ],
            ),
          ),
        );
      },
    );
  }
}