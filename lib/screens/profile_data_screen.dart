import 'package:flutter/material.dart';
import '../services/pod_profile_service.dart';

class ProfileDataScreen extends StatefulWidget {
  const ProfileDataScreen({super.key});

  @override
  State<ProfileDataScreen> createState() => _ProfileDataScreenState();
}

class _ProfileDataScreenState extends State<ProfileDataScreen> {
  final PodProfileService _profileService = PodProfileService();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });

    final profile = await _profileService.readCareerProfile();

    if (!mounted) return;

    if (profile != null) {
      _fullNameController.text = profile['fullName']?.toString() ?? '';
      _emailController.text = profile['email']?.toString() ?? '';
      _phoneController.text = profile['phone']?.toString() ?? '';
      _summaryController.text = profile['summary']?.toString() ?? '';
      _skillsController.text = profile['skills']?.toString() ?? '';
      _experienceController.text = profile['experience']?.toString() ?? '';
      _educationController.text = profile['education']?.toString() ?? '';
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isSaving = true;
    });

    final success = await _profileService.saveCareerProfile(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      summary: _summaryController.text.trim(),
      skills: _skillsController.text.trim(),
      experience: _experienceController.text.trim(),
      education: _educationController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Profile saved securely to your Solid Pod.'
              : 'Failed to save profile to your Solid Pod.',
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 900,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PROFILE DATA',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Your career data.\nYour control.',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Store your professional information securely inside your personal Solid Pod.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 40),
              _buildTextField(
                label: 'Full Name',
                controller: _fullNameController,
                hint: 'Enter your full name',
              ),
              _buildTextField(
                label: 'Email',
                controller: _emailController,
                hint: 'Enter your email address',
              ),
              _buildTextField(
                label: 'Phone',
                controller: _phoneController,
                hint: 'Enter your phone number',
              ),
              _buildTextField(
                label: 'Professional Summary',
                controller: _summaryController,
                maxLines: 5,
                hint: 'Write a short professional summary',
              ),
              _buildTextField(
                label: 'Skills',
                controller: _skillsController,
                maxLines: 4,
                hint: 'Example: Flutter, Python, SQL, Project Management',
              ),
              _buildTextField(
                label: 'Experience',
                controller: _experienceController,
                maxLines: 6,
                hint: 'Add your work experience',
              ),
              _buildTextField(
                label: 'Education',
                controller: _educationController,
                maxLines: 5,
                hint: 'Add your education details',
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveProfile,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.cloud_upload_outlined),
                  label: Text(
                    _isSaving
                        ? 'Saving to Solid Pod...'
                        : 'Save securely to my Solid Pod',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 18,
                    color: Colors.green,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Your data is stored in your personal Solid Pod.',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _summaryController.dispose();
    _skillsController.dispose();
    _experienceController.dispose();
    _educationController.dispose();
    super.dispose();
  }
}
