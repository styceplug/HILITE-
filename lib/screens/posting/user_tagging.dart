import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/repo/user_repo.dart';
import '../../models/user_model.dart';
import 'dart:async';


class UserTaggingSheet extends StatefulWidget {
  final List<UserModel> initiallySelected;
  final Function(List<UserModel>) onComplete;

  const UserTaggingSheet({
    Key? key,
    required this.initiallySelected,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<UserTaggingSheet> createState() => _UserTaggingSheetState();
}

class _UserTaggingSheetState extends State<UserTaggingSheet> {
  final UserRepo userRepo = Get.find<UserRepo>();
  final TextEditingController _searchController = TextEditingController();

  List<UserModel> searchResults = [];
  late List<UserModel> selectedUsers;

  bool isSearching = false;
  bool hasSearched = false; // Tracks if a search has been attempted
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    selectedUsers = List.from(widget.initiallySelected);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // --- 1. SMART NAME RESOLUTION ---
  String _getDisplayName(UserModel user) {
    // If you have specific roles/details, check them first
    // Assuming your UserModel has these fields based on previous context:
    if (user.role == 'club' && user.clubDetails?.clubName != null) {
      return user.clubDetails!.clubName!;
    }
    if (user.role == 'agent' && user.agentDetails?.agencyName != null) {
      return user.agentDetails!.agencyName!;
    }

    // Fallback to name, then username
    if (user.name != null && user.name!.trim().isNotEmpty) {
      return user.name!;
    }
    return user.username ?? 'Unknown';
  }

  // --- 2. DEBOUNCED SEARCH ---
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.trim().isEmpty) {
      setState(() {
        searchResults.clear();
        hasSearched = false;
      });
      return;
    }

    // Wait 500ms after the user stops typing before hitting the API
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _executeSearch(query.trim());
    });
  }

  Future<void> _executeSearch(String query) async {
    setState(() {
      isSearching = true;
      hasSearched = true;
    });

    try {
      final response = await userRepo.searchUsersForMentions(query: query);

      if (response.statusCode == 200 && mounted) {
        final dynamic responseData = response.body['data'];
        List<dynamic> rawList = [];

        if (responseData is List) {
          rawList = responseData;
        } else if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('users') && responseData['users'] is List) {
            rawList = responseData['users'];
          } else {
            rawList = responseData.values.firstWhere((v) => v is List, orElse: () => []) as List;
          }
        }

        setState(() {
          searchResults = rawList.map((e) => UserModel.fromJson(e)).toList();
        });
      }
    } catch (e) {
      debugPrint("Tag search error: $e");
    } finally {
      if (mounted) setState(() => isSearching = false);
    }
  }

  // --- 3. SMART SELECTION LOGIC ---
  void _toggleUserSelection(UserModel user) {
    setState(() {
      final isAlreadySelected = selectedUsers.any((u) => u.id == user.id);

      if (isAlreadySelected) {
        selectedUsers.removeWhere((u) => u.id == user.id);
      } else {
        selectedUsers.add(user);

        // UX Polish: Clear search and hide keyboard after picking someone
        _searchController.clear();
        searchResults.clear();
        hasSearched = false;
        FocusScope.of(context).unfocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard on tap outside
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Color(0xFF161E2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // --- HEADER ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text("Cancel", style: TextStyle(color: Colors.white54, fontSize: 16)),
                  ),
                  const Text("Tag People", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {
                      widget.onComplete(selectedUsers);
                      Get.back();
                    },
                    child: const Text("Done", style: TextStyle(color: Colors.blueAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            // --- SELECTED CHIPS ---
            if (selectedUsers.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: selectedUsers.map((user) => Chip(
                    backgroundColor: Colors.blueAccent.withOpacity(0.15),
                    labelStyle: const TextStyle(color: Colors.blueAccent, fontSize: 13, fontWeight: FontWeight.w600),
                    deleteIcon: const Icon(Icons.close, color: Colors.blueAccent, size: 16),
                    label: Text('@${user.username ?? ''}'),
                    onDeleted: () => _toggleUserSelection(user),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  )).toList(),
                ),
              ),

            // --- SEARCH BAR ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search for a user...",
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                  prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.5)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.cancel, color: Colors.white.withOpacity(0.5), size: 20),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                  )
                      : null,
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // --- RESULTS LIST ---
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isSearching) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.blueAccent, strokeWidth: 2),
      );
    }

    if (!hasSearched && searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search, size: 48, color: Colors.white.withOpacity(0.2)),
            const SizedBox(height: 16),
            Text("Search for people to tag", style: TextStyle(color: Colors.white.withOpacity(0.5))),
          ],
        ),
      );
    }

    if (hasSearched && searchResults.isEmpty) {
      return Center(
        child: Text("No users found", style: TextStyle(color: Colors.white.withOpacity(0.5))),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final user = searchResults[index];
        final isSelected = selectedUsers.any((u) => u.id == user.id);
        final hasImage = user.profilePicture != null && user.profilePicture!.isNotEmpty;
        final displayName = _getDisplayName(user);

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: CircleAvatar(
            radius: 22,
            backgroundColor: Colors.blueAccent.withOpacity(0.2),
            backgroundImage: hasImage ? NetworkImage(user.profilePicture!) : null,
            child: !hasImage ? Text(
              (user.username ?? '@').substring(0, 1).toUpperCase(),
              style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
            ) : null,
          ),
          title: Text(
              displayName,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)
          ),
          subtitle: Text(
              '@${user.username ?? ''}',
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)
          ),
          trailing: isSelected
              ? const Icon(Icons.check_circle, color: Colors.blueAccent, size: 28)
              : Icon(Icons.circle_outlined, color: Colors.white.withOpacity(0.2), size: 28),
          onTap: () => _toggleUserSelection(user),
        );
      },
    );
  }
}