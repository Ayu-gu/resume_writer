import 'dart:convert';
import 'job_analysis_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class JobInputScreen extends StatefulWidget {
  const JobInputScreen({super.key});

  @override
  State<JobInputScreen> createState() => _JobInputScreenState();
}

class _JobInputScreenState extends State<JobInputScreen> {
  final TextEditingController _jobDescriptionController =
      TextEditingController();

  bool _isAnalysing = false;

  static const Color _background = Color(0xFF050505);
  static const Color _surface = Color(0xFF0D0D0D);
  static const Color _border = Color(0xFF242424);
  static const Color _primaryText = Color(0xFFF5F5F5);
  static const Color _secondaryText = Color(0xFFA3A3A3);
  static const Color _accent = Color(0xFF22C55E);

  @override
  void dispose() {
    _jobDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _analyseJob() async {
    final jobDescription = _jobDescriptionController.text.trim();

    if (jobDescription.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please paste a job description first.'),
        ),
      );
      return;
    }

    setState(() {
      _isAnalysing = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/analyse-job'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'jobDescription': jobDescription,
        }),
      );

      if (response.body.isEmpty) {
        throw Exception('Backend returned an empty response.');
      }

      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        final Map<String, dynamic> analysis =
            data['analysis'] as Map<String, dynamic>;

        debugPrint('===== JOB ANALYSIS =====');
        debugPrint('Job title: ${analysis['jobTitle']}');
        debugPrint('Company: ${analysis['companyName']}');
        debugPrint('Summary: ${analysis['summary']}');
        debugPrint('Required skills: ${analysis['requiredSkills']}');
        debugPrint('Preferred skills: ${analysis['preferredSkills']}');
        debugPrint('Keywords: ${analysis['keywords']}');
        debugPrint('Responsibilities: ${analysis['responsibilities']}');
        debugPrint('Qualifications: ${analysis['qualifications']}');
        debugPrint(
          'Experience requirements: ${analysis['experienceRequirements']}',
        );
        debugPrint('========================');

        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JobAnalysisScreen(
              analysis: analysis,
            ),
          ),
        );
      } else {
        throw Exception(
          data['error'] ?? 'Failed to analyse job.',
        );
      }
    } catch (error) {
      debugPrint('Analyse job error: $error');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAnalysing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 48,
          vertical: 56,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NEW APPLICATION',
                  style: TextStyle(
                    color: _accent,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Tailor your resume\nto the role.',
                  style: TextStyle(
                    color: _primaryText,
                    fontSize: 52,
                    height: 1.05,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1.5,
                  ),
                ),
                const SizedBox(height: 24),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 760),
                  child: Text(
                    'Paste the job description below. ResumeWriter will analyse '
                    'the role, identify the key requirements and compare them '
                    'with your professional profile.',
                    style: TextStyle(
                      color: _secondaryText,
                      fontSize: 19,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 56),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: _surface,
                    border: Border.all(
                      color: _border,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text(
                            'JOB DESCRIPTION',
                            style: TextStyle(
                              color: _primaryText,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                          ),
                          Spacer(),
                          Icon(
                            Icons.description_outlined,
                            color: _accent,
                            size: 22,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _jobDescriptionController,
                        minLines: 14,
                        maxLines: 22,
                        style: const TextStyle(
                          color: _primaryText,
                          fontSize: 16,
                          height: 1.5,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Paste the full job advertisement here...',
                          hintStyle: const TextStyle(
                            color: Color(0xFF6F6F6F),
                          ),
                          filled: true,
                          fillColor: _background,
                          contentPadding: const EdgeInsets.all(22),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(2),
                            borderSide: const BorderSide(
                              color: _border,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(2),
                            borderSide: const BorderSide(
                              color: _border,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(2),
                            borderSide: const BorderSide(
                              color: _accent,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _isAnalysing ? null : _analyseJob,
                          icon: _isAnalysing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              : const Icon(
                                  Icons.arrow_forward,
                                  size: 20,
                                ),
                          label: Text(
                            _isAnalysing ? 'Analysing Job...' : 'Analyse Job',
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: _accent,
                            foregroundColor: Colors.black,
                            disabledBackgroundColor: _accent,
                            disabledForegroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                            ),
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
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                const Row(
                  children: [
                    Icon(
                      Icons.lock_outline,
                      color: _accent,
                      size: 18,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Your job description is used only for analysis and is not stored permanently.',
                        style: TextStyle(
                          color: _secondaryText,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
