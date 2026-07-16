import 'package:flutter/material.dart';

class JobAnalysisScreen extends StatelessWidget {
  final Map<String, dynamic> analysis;

  const JobAnalysisScreen({
    super.key,
    required this.analysis,
  });

  static const Color _background = Color(0xFF050505);
  static const Color _surface = Color(0xFF0D0D0D);
  static const Color _border = Color(0xFF242424);
  static const Color _primaryText = Color(0xFFF5F5F5);
  static const Color _secondaryText = Color(0xFFA3A3A3);
  static const Color _accent = Color(0xFF22C55E);

  @override
  Widget build(BuildContext context) {
    final requiredSkills = List<String>.from(analysis['requiredSkills'] ?? []);

    final preferredSkills =
        List<String>.from(analysis['preferredSkills'] ?? []);

    final keywords = List<String>.from(analysis['keywords'] ?? []);

    final responsibilities =
        List<String>.from(analysis['responsibilities'] ?? []);

    final qualifications = List<String>.from(analysis['qualifications'] ?? []);

    final experienceRequirements =
        List<String>.from(analysis['experienceRequirements'] ?? []);

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
              ],
            ),
          ),
        ),
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
