// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewDialog extends StatefulWidget {
  const ReviewDialog({super.key});

  @override
  State<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  final Rxn<Uint8List> imageBytes = Rxn<Uint8List>();
  final RxBool isLoading = false.obs;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  Future<String?> uploadToImgbb(Uint8List imageBytes) async {
    const apiKey = 'd31defbd1e775a2d2f576bf33fcdc446'; // your key
    final url = Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey');
    final base64Image = base64Encode(imageBytes);

    final response = await http.post(url, body: {'image': base64Image});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data']['url'];
    } else {
      debugPrint('❌ Image upload failed: ${response.body}');
      return null;
    }
  }

  Future<void> _pickImage() async {
    final bytes = await ImagePickerWeb.getImageAsBytes();
    if (bytes != null) imageBytes.value = bytes;
  }

  Future<void> _submitReview() async {
    if (imageBytes.value == null ||
        _titleController.text.isEmpty ||
        _descController.text.isEmpty) {
      Get.snackbar("⚠️ Missing Info", "Please fill all fields and select an image");
      return;
    }

    isLoading.value = true;

    final imageUrl = await uploadToImgbb(imageBytes.value!);
    if (imageUrl == null) {
      isLoading.value = false;
      Get.snackbar("❌ Upload Failed", "Could not upload image");
      return;
    }

    await FirebaseFirestore.instance.collection('reviews').add({
      'title': _titleController.text.trim(),
      'description': _descController.text.trim(),
      'imgUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });

    isLoading.value = false;
    Get.back();
    Get.snackbar("✅ Success", "Your review has been added");
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.white24, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 10),
                )
              ],
              borderRadius: BorderRadius.circular(25),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.reviews, color: Colors.white, size: 28),
                      SizedBox(width: 8),
                      Text(
                        "Add Your Review",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Obx(() {
                    return GestureDetector(
                      onTap: _pickImage,
                      child: imageBytes.value == null
                          ? Container(
                              height: 150.h,
                              width: 150.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white.withOpacity(0.1),
                                border: Border.all(color: Colors.white30),
                              ),
                              child: const Center(
                                child: Icon(Icons.add_a_photo,
                                    color: Colors.white70, size: 45),
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.memory(
                                imageBytes.value!,
                                height: 150.h,
                                width: 150.w,
                                fit: BoxFit.cover,
                              ),
                            ),
                    );
                  }),

                  const SizedBox(height: 20),

                  TextField(
                    controller: _titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.title, color: Colors.white70),
                      labelText: "Title",
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Colors.white30),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Colors.cyanAccent),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: _descController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 3,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.description, color: Colors.white70),
                      labelText: "Description",
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Colors.white30),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Colors.cyanAccent),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // 🔹 Action Buttons (Reactive)
                  Obx(() {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: isLoading.value ? null : () => Get.back(),
                          icon: const Icon(Icons.close, color: Colors.white70),
                          label: const Text(
                            "Cancel",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: isLoading.value ? null : _submitReview,
                          icon: isLoading.value
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.send, color: Colors.white),
                          label: const Text("Submit"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0A5CCF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            shadowColor: Colors.cyanAccent.withOpacity(0.5),
                            elevation: 10,
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
