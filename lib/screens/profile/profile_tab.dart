import 'package:dhukuti/providers/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../routes/app_routes.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  bool _editing = false;
  
  String? _lastSyncedUid;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    try {
      await context.read<UserProvider>().updateUserProfile(
        name: _nameController.text,
        address: _addressController.text,
        email: _emailController.text,
      );
      setState(() => _editing = false);
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile Updated")));
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.userModel;

    if (userProvider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text("Failed to load profile", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(userProvider.errorMessage!, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    if (user == null) return const Center(child: CircularProgressIndicator());

    if (_lastSyncedUid != user.uid || (_lastSyncedUid == null && user != null)) {
       if (!_editing) {
          _nameController.text = user.name ?? '';
          _addressController.text = user.address ?? '';
          _emailController.text = user.email ?? '';
          _lastSyncedUid = user.uid;
       }
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final headerHeight = screenHeight * 0.2;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🎨 Header with Avatar
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: headerHeight,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -50,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.grey[200],
                      child: const Icon(Icons.person, size: 60, color: Colors.grey),
                    ),
                  ),
                ),
                if (!_editing)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 10,
                    right: 10,
                    child: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: () => setState(() => _editing = true),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 60),
            
            // 📝 User Info Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                   Text(
                    user.name ?? "Set Name",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    user.phone,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const Divider(height: 40),
                  
                  _buildField("Address", _addressController, Icons.location_on),
                  _buildField("Email", _emailController, Icons.email),
                  
                  const SizedBox(height: 30),
                  
                  if (_editing)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _editing = false;
                                _nameController.text = user.name ?? '';
                                _addressController.text = user.address ?? '';
                                _emailController.text = user.email ?? '';
                              });
                            },
                            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                            child: const Text("Cancel"),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _save,
                            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                            child: const Text("Save Changes"),
                          ),
                        ),
                      ],
                    )
                  else
                     const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        enabled: _editing,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: label,
          filled: !_editing,
          fillColor: _editing ? null : Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
        ),
      ),
    );
  }
}
