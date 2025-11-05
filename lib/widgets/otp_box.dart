import 'package:flutter/material.dart';
import 'package:sms_autofill/sms_autofill.dart';


class OtpInput extends StatefulWidget {
  final int length;
  final double boxSize;
  final ValueChanged<String> onCompleted;

  const OtpInput({
    super.key,
    this.length = 4,
    this.boxSize = 50,
    required this.onCompleted,
  });

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> with CodeAutoFill {
  late List<TextEditingController> controllers;
  late List<FocusNode> focusNodes;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(widget.length, (_) => TextEditingController());
    focusNodes = List.generate(widget.length, (_) => FocusNode());
    listenForCode();
  }

  @override
  void dispose() {
    cancel();
    for (var c in controllers) {
      c.dispose();
    }
    for (var f in focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  void codeUpdated() {
    if (code != null && code!.length >= widget.length) {
      for (int i = 0; i < widget.length; i++) {
        controllers[i].text = code![i];
      }
      widget.onCompleted(code!.substring(0, widget.length));
    }
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty && index < widget.length - 1) {
      FocusScope.of(context).requestFocus(focusNodes[index + 1]);
    }
    if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(focusNodes[index - 1]);
    }

    final otp = controllers.map((c) => c.text).join();
    if (otp.length == widget.length) {
      widget.onCompleted(otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(widget.length, (index) {
        return SizedBox(
          width: widget.boxSize,
          height: widget.boxSize,
          child: TextField(
            controller: controllers[index],
            focusNode: focusNodes[index],
            maxLength: 1,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (value) => _onChanged(value, index),
          ),
        );
      }),
    );
  }
}