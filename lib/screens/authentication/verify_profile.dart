import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/routes/routes.dart';
import 'package:hilite/utils/app_constants.dart';
import 'package:hilite/utils/dimensions.dart';
import 'package:hilite/widgets/snackbars.dart';
import 'package:url_launcher/url_launcher.dart';

class VerifyProfile extends StatefulWidget {
  const VerifyProfile({super.key});

  @override
  State<VerifyProfile> createState() => _VerifyProfileState();
}

class _VerifyProfileState extends State<VerifyProfile> {

  Future<void> openMailApp() async {
    final apps = <_MailApp>[];

    // Define known mail app schemes
    final mailApps = {
      'Apple Mail': Uri(scheme: 'mailto', path: 'support@example.com'),
      'Gmail': Uri(scheme: 'googlegmail', path: 'co'),
      'Outlook': Uri(scheme: 'ms-outlook', path: ''),
      'Yahoo Mail': Uri(scheme: 'ymail', path: ''),
    };

    // Check which apps are available
    for (final entry in mailApps.entries) {
      if (await canLaunchUrl(entry.value)) {
        apps.add(_MailApp(name: entry.key, uri: entry.value));
      }
    }

    // If no mail app is found, fallback
    if (apps.isEmpty) {
      const gmailWeb = 'https://mail.google.com/';
      if (await canLaunchUrl(Uri.parse(gmailWeb))) {
        await launchUrl(Uri.parse(gmailWeb), mode: LaunchMode.externalApplication);
      } else {
        CustomSnackBar.showToast(message: 'No mail app found.');
      }
      return;
    }

    // Show modal to pick an app
    if (apps.length == 1) {
      await launchUrl(apps.first.uri);
    } else {
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => _MailAppPicker(apps: apps),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0E1E36), Color(0xFF162A4C), Color(0xFF1F3A64)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              Container(
                height: Dimensions.height100*1.5,
                width: Dimensions.width100*1.5,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 2),
                  image: DecorationImage(
                    image: AssetImage(AppConstants.getGifAsset('mobile')),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Celebration title
              const Text(
                "Welcome to HiLite 🎉",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Description text
              const Text(
                "You’ve successfully joined the HiLite community!\n"
                "Please check your email inbox (and spam folder) for a verification link to activate your profile.",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Call to action button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0E1E36),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: openMailApp,
                child: const Text(
                  "Open Mail App",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 20),


              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0E1E36),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: Colors.white, width: 1),
                ),
                onPressed: (){
                  Get.offAllNamed(AppRoutes.loginScreen);
                },
                child: const Text(
                  "Go back to Login Screen",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),

              const Spacer(),

              // Footer hint
              const Text(
                "Didn’t get the email? Check your spam folder or try again.",
                style: TextStyle(color: Colors.white54, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }


}


class _MailApp {
  final String name;
  final Uri uri;

  _MailApp({required this.name, required this.uri});
}

class _MailAppPicker extends StatelessWidget {
  final List<_MailApp> apps;

  const _MailAppPicker({required this.apps});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Choose Mail App",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 12),
            ...apps.map((app) => ListTile(
              leading: Icon(
                _getMailAppIcon(app.name),
                color: const Color(0xFF0E1E36),
              ),
              title: Text(app.name, style: const TextStyle(fontFamily: 'Poppins')),
              onTap: () async {
                Navigator.pop(context);
                await launchUrl(app.uri);
              },
            )),
          ],
        ),
      ),
    );
  }

  IconData _getMailAppIcon(String name) {
    switch (name) {
      case 'Gmail':
        return Icons.mail_outline;
      case 'Outlook':
        return Icons.alternate_email;
      case 'Yahoo Mail':
        return Icons.email_outlined;
      default:
        return Icons.mail;
    }
  }
}