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
  
  // Track if we have synced with user model
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

    // Sync controllers if user changes or first load
    if (_lastSyncedUid != user.uid || (_lastSyncedUid == null && user != null)) {
       // Only update text if we are NOT editing to prevent overwriting user input while typing if stream updates
       if (!_editing) {
          _nameController.text = user.name ?? '';
          _addressController.text = user.address ?? '';
          _emailController.text = user.email ?? '';
          _lastSyncedUid = user.uid;
       }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            child: Icon(Icons.person, size: 50),
          ),
          const SizedBox(height: 10),
          Text(user.phone, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 20),
          
          _buildField("Name", _nameController),
          _buildField("Address", _addressController),
          _buildField("Email", _emailController),
          
          const SizedBox(height: 20),
          if (_editing)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(onPressed: () {
                    setState(() {
                       _editing = false;
                       // Reset to original values
                       _nameController.text = user.name ?? '';
                       _addressController.text = user.address ?? '';
                       _emailController.text = user.email ?? '';
                    });
                }, child: const Text("Cancel")),
                ElevatedButton(onPressed: _save, child: const Text("Save")),
              ],
            )
          else
            ElevatedButton(onPressed: () => setState(() => _editing = true), child: const Text("Edit Profile")),

          const SizedBox(height: 40),
          OutlinedButton.icon(
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text("Logout", style: TextStyle(color: Colors.red)),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) context.go(AppRoutes.login);
            },
          )
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        enabled: _editing,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
