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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ReviewDialog extends StatelessWidget {
  ReviewDialog({super.key});

  final Rxn<Uint8List> imageBytes = Rxn<Uint8List>();
  final RxBool isLoading = false.obs;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  // ----------------- IMAGE UPLOAD -----------------
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

  Future<void> pickImage() async {
    final bytes = await ImagePickerWeb.getImageAsBytes();
    if (bytes != null) imageBytes.value = bytes;
  }

  Future<void> submitReview() async {
    if (imageBytes.value == null ||
        titleController.text.isEmpty ||
        descController.text.isEmpty) {
      Get.snackbar(
        "⚠️ Missing Info",
        "Please fill all fields and select an image",
        backgroundColor: Colors.red.shade300,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    final imageUrl = await uploadToImgbb(imageBytes.value!);
    if (imageUrl == null) {
      isLoading.value = false;
      Get.snackbar(
        "❌ Upload Failed",
        "Could not upload image",
        backgroundColor: Colors.red.shade300,
        colorText: Colors.white,
      );
      return;
    }

    await FirebaseFirestore.instance.collection('reviews').add({
      'title': titleController.text.trim(),
      'description': descController.text.trim(),
      'imgUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });

    isLoading.value = false;
    Get.back();
    Get.snackbar(
      "✅ Success",
      "Your review has been added",
      backgroundColor: Colors.green.shade400,
      colorText: Colors.white,
    );
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
                ),
              ],
              borderRadius: BorderRadius.circular(25),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ---------- HEADER ----------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      FaIcon(
                        FontAwesomeIcons.star,
                        color: Colors.white,
                        size: 28,
                      ),
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

                  // ---------- IMAGE PICKER ----------
                  Obx(() {
                    return GestureDetector(
                      onTap: pickImage,
                      child:
                          imageBytes.value == null
                              ? Container(
                                height: 150.h,
                                width: 150.w,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white.withOpacity(0.1),
                                  border: Border.all(color: Colors.white30),
                                ),
                                child: const Center(
                                  child: FaIcon(
                                    FontAwesomeIcons.image,
                                    color: Colors.white70,
                                    size: 45,
                                  ),
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

                  // ---------- TITLE ----------
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 1,
                    textAlignVertical:
                        TextAlignVertical.top, // ensures text starts at top
                    decoration: InputDecoration(
                      prefix: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 8.h,
                        ),
                        child: FaIcon(
                          FontAwesomeIcons.fileText,
                          color: Colors.white70,
                          size: 20.sp,
                        ),
                      ),
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
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12.h,
                        horizontal: 10.w,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // ---------- DESCRIPTION ----------
                  TextField(
                    controller: descController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 3,
                    textAlignVertical:
                        TextAlignVertical.top, // ensures text starts at top
                    decoration: InputDecoration(
                      prefix: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 8.h,
                        ),
                        child: FaIcon(
                          FontAwesomeIcons.alignLeft,
                          color: Colors.white70,
                          size: 20.sp,
                        ),
                      ),
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
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12.h,
                        horizontal: 10.w,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ---------- ACTION BUTTONS ----------
                  Obx(() {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: isLoading.value ? null : () => Get.back(),
                          icon: const FaIcon(
                            FontAwesomeIcons.xmark,
                            color: Colors.white70,
                          ),
                          label: const Text(
                            "Cancel",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: isLoading.value ? null : submitReview,
                          icon:
                              isLoading.value
                                  ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : const FaIcon(
                                    FontAwesomeIcons.paperPlane,
                                    color: Colors.white,
                                  ),
                          label: const Text("Submit"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0A5CCF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
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
