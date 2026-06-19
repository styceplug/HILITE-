import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/user_model.dart';
import '../routes/routes.dart';

class TaggedUsersSheet extends StatelessWidget {
  final List<UserModel> taggedUsers;

  const TaggedUsersSheet({Key? key, required this.taggedUsers}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5, // Max 50% of screen
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF161E2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle indicator
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const Text(
            "Tagged in this post",
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: taggedUsers.length,
              itemBuilder: (context, index) {
                final user = taggedUsers[index];
                final hasImage = user.profilePicture != null && user.profilePicture!.isNotEmpty;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueAccent.withOpacity(0.2),
                    backgroundImage: hasImage ? NetworkImage(user.profilePicture!) : null,
                    child: !hasImage
                        ? Text((user.displayName ?? '@').substring(0, 1).toUpperCase(), style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold))
                        : null,
                  ),
                  title: Text(user.displayName ?? 'Unknown', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text(user.name ?? '', style: TextStyle(color: Colors.white.withOpacity(0.5))),
                  trailing: ElevatedButton(
                    onPressed: () {

                      Get.back();
                      Get.toNamed(AppRoutes.othersProfileScreen, arguments: {
                        'targetId': user.id
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.1),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    ),
                    child: const Text("View", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}