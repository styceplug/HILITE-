import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hilite/utils/colors.dart';
import 'package:hilite/utils/dimensions.dart';


class CountryService {
  static final CountryService _instance = CountryService._internal();
  factory CountryService() => _instance;
  CountryService._internal();

  List<CountryData>? _cachedCountries;
  Future<List<CountryData>>? _loadingFuture;

  // Load countries with caching
  Future<List<CountryData>> loadCountries() async {
    // Return cached data if available
    if (_cachedCountries != null) {
      return _cachedCountries!;
    }

    // If already loading, return the existing future
    if (_loadingFuture != null) {
      return _loadingFuture!;
    }

    // Start loading
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

  // Get countries synchronously (returns null if not loaded)
  List<CountryData>? getCachedCountries() => _cachedCountries;

  // Check if data is loaded
  bool get isLoaded => _cachedCountries != null;

  // Preload - call this in your app initialization
  Future<void> preload() async {
    await loadCountries();
  }

  // Clear cache if needed (e.g., for testing or updates)
  void clearCache() {
    _cachedCountries = null;
  }
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
  late Future<List<CountryData>> _countriesFuture;

  @override
  void initState() {
    super.initState();
    _countriesFuture = _countryService.loadCountries();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CountryData>>(
      future: _countriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text("No countries available");
        }

        final countries = snapshot.data!;
        final countryNames = countries.map((c) => c.name).toList();

        final selectedCountryObj = widget.selectedCountry != null
            ? countries.firstWhere(
              (c) => c.name == widget.selectedCountry,
          orElse: () => countries.first,
        )
            : countries.first;

        final stateNames = selectedCountryObj.states.map((s) => s.name).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // COUNTRY
            DropdownButtonFormField<String>(
              value: widget.selectedCountry,
              decoration: _inputDecoration(),
              borderRadius: BorderRadius.circular(Dimensions.radius15),
              style: TextStyle(
                color: AppColors.black,
                fontFamily: 'Poppins',

              ),
              items: countryNames.map((country) {
                return DropdownMenuItem(value: country, child: Text(country));
              }).toList(),
              onChanged: (value) {
                widget.onCountryChanged(value);
                widget.onStateChanged(null);
              },
              hint: Text(
                "Choose a country",
                style: TextStyle(
                  color: AppColors.black.withOpacity(0.5),
                  fontSize: Dimensions.font16
                ),
              ),
            ),

            SizedBox(height: 20),

            // STATE
            DropdownButtonFormField<String>(
              value: widget.selectedState,
              borderRadius: BorderRadius.circular(Dimensions.radius15),
              style: TextStyle(
                color: Theme.of(context).hintColor,
                fontFamily: 'Poppins',
                  fontSize: Dimensions.font15

              ),
              decoration: _inputDecoration(),
              items: stateNames.map((state) {
                return DropdownMenuItem(value: state, child: Text(state));
              }).toList(),
              onChanged: widget.onStateChanged,
              hint: Text(
                "Choose a state",
                style: TextStyle(
                    color: AppColors.black.withOpacity(0.5),
                    fontFamily: 'Poppins',
                    fontSize: Dimensions.font16

                ),
              ),
            ),
          ],
        );
      },
    );
  }

  InputDecoration _inputDecoration() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final BorderRadius borderRadius = BorderRadius.circular(Dimensions.radius15);
    final Color textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final Color fillColor = theme.inputDecorationTheme.fillColor ??
        (isDark ? Colors.white10 : const Color(0xFFDBD0C8).withOpacity(0.1));
    final Color borderColor = theme.dividerColor;
    final Color focusColor = theme.colorScheme.primary.withOpacity(0.6);
    final Color enabledBorderColor = theme.colorScheme.secondary;

    return InputDecoration(
      filled: true,
      fillColor: fillColor,
      hintStyle: TextStyle(
        color: textColor.withOpacity(0.5),
        fontFamily: 'Poppins',
      ),
      border: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: enabledBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: focusColor),
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _countriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text("No countries available");
        }

        final countries = snapshot.data!;

        return DropdownButtonFormField<String>(
          value: widget.selectedCountry,
          decoration: _inputDecoration(context),
          style: TextStyle(
            color: Theme.of(context).hintColor,
            fontFamily: 'Poppins',
          ),
          items: countries.map((country) {
            return DropdownMenuItem(value: country, child: Text(country));
          }).toList(),
          onChanged: widget.onCountryChanged,
          hint: Text(
            "Choose a country",
            style: TextStyle(
              color: Theme.of(context).hintColor,
              fontFamily: 'Poppins',
            ),
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final Color fillColor = theme.inputDecorationTheme.fillColor ??
        (isDark ? Colors.white10 : const Color(0xFFDBD0C8).withOpacity(0.1));
    final Color borderColor = theme.dividerColor;
    final Color focusColor = theme.colorScheme.primary.withOpacity(0.6);
    final Color enabledBorderColor = theme.colorScheme.secondary;

    return InputDecoration(
      filled: true,
      fillColor: fillColor,
      hintStyle: TextStyle(
        color: textColor.withOpacity(0.5),
        fontFamily: 'Poppins',
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: enabledBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: focusColor),
      ),
    );
  }
}