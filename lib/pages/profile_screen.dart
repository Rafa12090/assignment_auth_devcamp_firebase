import 'dart:io';

import 'package:assingment_auth_devcamp_firebase/pages/profile_image_picker.dart';
import 'package:assingment_auth_devcamp_firebase/utils/validators.dart';
import 'package:assingment_auth_devcamp_firebase/widgets/custom_button.dart';
import 'package:assingment_auth_devcamp_firebase/widgets/custom_text_form_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  //DateTime? _dob;
  String _profileImageUrl = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
  setState(() {
    _isLoading = true;
  });

  try {
    User? user = _auth.currentUser;
    if (user != null) {
      
      String userEmail = user.email ?? '';

      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: userEmail)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = querySnapshot.docs.first;

        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        setState(() {
          _firstNameController.text = data['first name'] ?? '';
          _lastNameController.text = data['last name'] ?? '';
          _ageController.text = data['age']?.toString() ?? '';
          _profileImageUrl = data['profileImageUrl'] ?? '';
        });
      } else {
        // Handle case when no matching document is found
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User data not found')),
        );
      }
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error loading user data: $e')),
    );
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}


  Future<void> _updateProfile() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() {
    _isLoading = true;
  });

  try {
    User? user = _auth.currentUser;
    if (user != null) {
      
      String userEmail = user.email ?? '';

      
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: userEmail)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        
        DocumentSnapshot doc = querySnapshot.docs.first;

        
        await doc.reference.update({
          'first name': _firstNameController.text.trim(),
          'last name': _lastNameController.text.trim(),
          'age': int.parse(_ageController.text.trim()),
          'profileImageUrl': _profileImageUrl,
        });

        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      } else {
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found')),
        );
      }
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to update profile: $e')),
    );
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}


  Future<void> _uploadImageToStorage(File image) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      Reference ref =
          _storage.ref().child('profile_images').child('${user.uid}.jpg');

      UploadTask uploadTask = ref.putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask;

      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      setState(() {
        _profileImageUrl = downloadUrl;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          InkWell(
              onTap: () {
                _auth.signOut();
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(
                  Icons.logout,
                  color: Colors.black,
                ),
              )),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ProfileImagePicker(
                      imageUrl: _profileImageUrl,
                      onImageSelected: _uploadImageToStorage,
                    ),
                    const SizedBox(height: 24),
                    CustomTextFormField(
                      controller: _firstNameController,
                      label: 'Name',
                      validator: Validators.nameValidation,
                      
                    ),
                    const SizedBox(height: 16),
                    CustomTextFormField(
                      controller: _lastNameController,
                      label: 'Last Name',
                      validator: Validators.nameValidation,
                      
                    ),
                    const SizedBox(height: 16),
                    CustomTextFormField(
                      controller: _ageController,
                      label: 'Age',
                      validator: Validators.ageValidation,
                      
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      onPressed: _updateProfile,
                      buttonText: 'Update Profile',
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}