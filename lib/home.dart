import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  final String title;

  const Home({
    super.key,
    required this.title,
  });

  static const Color _background = Color(0xFF050505);
  static const Color _surface = Color(0xFF0D0D0D);
  static const Color _border = Color(0xFF242424);
  static const Color _primaryText = Color(0xFFF5F5F5);
  static const Color _secondaryText = Color(0xFFA3A3A3);
  static const Color _accent = Color(0xFF22C55E);

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
                // Small introduction label
                const Text(
                  'RESUMEWRITER',
                  style: TextStyle(
                    color: _accent,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 28),

                // Main hero heading
                const Text(
                  'Your career data.\nYour control.',
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
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: const Text(
                    'Create tailored resumes using your professional data '
                    'stored securely in your Solid Pod.',
                    style: TextStyle(
                      color: _secondaryText,
                      fontSize: 20,
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),

                const SizedBox(height: 64),

                // Feature section
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 800;

                    if (isNarrow) {
                      return const Column(
                        children: [
                          _FeatureItem(
                            number: '01',
                            icon: Icons.lock_outline,
                            title: 'Privacy first',
                            description:
                                'Your professional data stays securely inside your Solid Pod.',
                          ),
                          SizedBox(height: 40),
                          _FeatureItem(
                            number: '02',
                            icon: Icons.auto_awesome,
                            title: 'AI powered',
                            description:
                                'Analyse job descriptions and create tailored applications.',
                          ),
                          SizedBox(height: 40),
                          _FeatureItem(
                            number: '03',
                            icon: Icons.verified_user_outlined,
                            title: 'Evidence based',
                            description:
                                'Generate content using only your verified professional profile.',
                          ),
                        ],
                      );
                    }

                    return const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _FeatureItem(
                            number: '01',
                            icon: Icons.lock_outline,
                            title: 'Privacy first',
                            description:
                                'Your professional data stays securely inside your Solid Pod.',
                          ),
                        ),
                        SizedBox(width: 48),
                        Expanded(
                          child: _FeatureItem(
                            number: '02',
                            icon: Icons.auto_awesome,
                            title: 'AI powered',
                            description:
                                'Analyse job descriptions and create tailored applications.',
                          ),
                        ),
                        SizedBox(width: 48),
                        Expanded(
                          child: _FeatureItem(
                            number: '03',
                            icon: Icons.verified_user_outlined,
                            title: 'Evidence based',
                            description:
                                'Generate content using only your verified professional profile.',
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 72),

                // Solid Pod status
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    color: _surface,
                    border: Border.all(color: _border),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.cloud_done_outlined,
                        color: _accent,
                        size: 32,
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Solid Pod connected',
                              style: TextStyle(
                                color: _primaryText,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Your professional profile is ready to be used securely.',
                              style: TextStyle(
                                color: _secondaryText,
                                fontSize: 15,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.check_circle,
                        color: _accent,
                        size: 22,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // Main CTA
                FilledButton.icon(
                  onPressed: () {
                    // We will connect this to New Resume later.
                  },
                  icon: const Icon(
                    Icons.arrow_forward,
                    size: 20,
                  ),
                  label: const Text('Create New Resume'),
                  style: FilledButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
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

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String number;
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.number,
    required this.icon,
    required this.title,
    required this.description,
  });

  static const Color _border = Color(0xFF242424);
  static const Color _primaryText = Color(0xFFF5F5F5);
  static const Color _secondaryText = Color(0xFFA3A3A3);
  static const Color _accent = Color(0xFF22C55E);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        top: 22,
        bottom: 8,
      ),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: _border,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                number,
                style: const TextStyle(
                  color: _accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _border,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: _accent,
                  size: 21,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            title,
            style: const TextStyle(
              color: _primaryText,
              fontSize: 21,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              color: _secondaryText,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
