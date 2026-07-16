import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/pod_profile_service.dart';
import 'resume_preview_screen.dart';

class JobAnalysisScreen extends StatefulWidget {
  final Map<String, dynamic> analysis;

  const JobAnalysisScreen({
    super.key,
    required this.analysis,
  });

  @override
  State<JobAnalysisScreen> createState() => _JobAnalysisScreenState();
}

class _JobAnalysisScreenState extends State<JobAnalysisScreen> {
  static const Color _background = Color(0xFF050505);
  static const Color _surface = Color(0xFF0D0D0D);
  static const Color _border = Color(0xFF242424);
  static const Color _primaryText = Color(0xFFF5F5F5);
  static const Color _secondaryText = Color(0xFFA3A3A3);
  static const Color _accent = Color(0xFF22C55E);

  final PodProfileService _profileService = PodProfileService();

  bool _isGenerating = false;

  Future<void> _generateResume() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      final careerProfile = await _profileService.readCareerProfile();

      if (careerProfile == null) {
        throw Exception(
          'Career profile could not be loaded from your Solid Pod.',
        );
      }

      final response = await http.post(
        Uri.parse('http://localhost:3000/generate-resume'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'careerProfile': careerProfile,
          'jobAnalysis': widget.analysis,
        }),
      );

      if (response.body.isEmpty) {
        throw Exception('Backend returned an empty response.');
      }

      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200 || data['success'] != true) {
        throw Exception(
          data['error'] ?? 'Failed to generate tailored resume.',
        );
      }

      final generatedResume = Map<String, dynamic>.from(data['resume']);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResumePreviewScreen(
            resume: generatedResume,
          ),
        ),
      );
    } catch (error) {
      debugPrint('Generate resume error: $error');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final analysis = widget.analysis;

    final requiredSkills = List<String>.from(analysis['requiredSkills'] ?? []);

    final preferredSkills =
        List<String>.from(analysis['preferredSkills'] ?? []);

    final keywords = List<String>.from(analysis['keywords'] ?? []);

    final responsibilities =
        List<String>.from(analysis['responsibilities'] ?? []);

    final qualifications = List<String>.from(analysis['qualifications'] ?? []);

    final experienceRequirements =
        List<String>.from(analysis['experienceRequirements'] ?? []);

    final matchedSkills = List<String>.from(analysis['matchedSkills'] ?? []);

    final missingSkills = List<String>.from(analysis['missingSkills'] ?? []);

    final matchingExperience =
        List<String>.from(analysis['matchingExperience'] ?? []);

    final resumeRecommendations =
        List<String>.from(analysis['resumeRecommendations'] ?? []);

    final int matchScore = (analysis['matchScore'] as num?)?.toInt() ?? 0;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _primaryText,
        elevation: 0,
        title: const Text(
          'Job Analysis',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 36,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 1000,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ANALYSIS COMPLETE',
                  style: TextStyle(
                    color: _accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  analysis['jobTitle'] ?? 'Unknown role',
                  style: const TextStyle(
                    color: _primaryText,
                    fontSize: 42,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  analysis['companyName'] ?? 'Unknown company',
                  style: const TextStyle(
                    color: _secondaryText,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 36),
                _buildMatchScore(matchScore),
                const SizedBox(height: 24),
                _buildSection(
                  title: 'SUMMARY',
                  child: Text(
                    analysis['summary'] ?? 'No summary available.',
                    style: const TextStyle(
                      color: _secondaryText,
                      fontSize: 17,
                      height: 1.6,
                    ),
                  ),
                ),
                _buildListSection(
                  title: 'MATCHED SKILLS',
                  items: matchedSkills,
                ),
                _buildListSection(
                  title: 'MISSING SKILLS',
                  items: missingSkills,
                ),
                _buildListSection(
                  title: 'RELEVANT EXPERIENCE',
                  items: matchingExperience,
                ),
                _buildListSection(
                  title: 'RESUME RECOMMENDATIONS',
                  items: resumeRecommendations,
                ),
                _buildListSection(
                  title: 'REQUIRED SKILLS',
                  items: requiredSkills,
                ),
                _buildListSection(
                  title: 'PREFERRED SKILLS',
                  items: preferredSkills,
                ),
                _buildListSection(
                  title: 'KEYWORDS',
                  items: keywords,
                ),
                _buildListSection(
                  title: 'RESPONSIBILITIES',
                  items: responsibilities,
                ),
                _buildListSection(
                  title: 'QUALIFICATIONS',
                  items: qualifications,
                ),
                _buildListSection(
                  title: 'EXPERIENCE REQUIREMENTS',
                  items: experienceRequirements,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: FilledButton.icon(
                    onPressed: _isGenerating ? null : _generateResume,
                    icon: _isGenerating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : const Icon(
                            Icons.auto_awesome,
                          ),
                    label: Text(
                      _isGenerating
                          ? 'Generating Tailored Resume...'
                          : 'Generate Tailored Resume',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.black,
                      disabledBackgroundColor: _accent,
                      disabledForegroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Row(
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      color: _accent,
                      size: 18,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Resume content will be generated using only verified career data read from your Solid Pod.',
                        style: TextStyle(
                          color: _secondaryText,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMatchScore(int score) {
    final double progress = score.clamp(0, 100) / 100;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: _surface,
        border: Border.all(
          color: _accent,
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            height: 92,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 92,
                  height: 92,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: _border,
                    color: _accent,
                  ),
                ),
                Text(
                  '$score%',
                  style: const TextStyle(
                    color: _primaryText,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 28),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PROFILE MATCH',
                  style: TextStyle(
                    color: _accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Based on the verified career data stored in your Solid Pod.',
                  style: TextStyle(
                    color: _secondaryText,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 24,
      ),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _surface,
        border: Border.all(
          color: _border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _accent,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildListSection({
    required String title,
    required List<String> items,
  }) {
    return _buildSection(
      title: title,
      child: items.isEmpty
          ? const Text(
              'No information found.',
              style: TextStyle(
                color: _secondaryText,
                fontSize: 16,
              ),
            )
          : Column(
              children: items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: 12,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(
                          top: 7,
                        ),
                        child: Icon(
                          Icons.circle,
                          color: _accent,
                          size: 7,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(
                            color: _primaryText,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}
