import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../services/pod_profile_service.dart';

class ResumePreviewScreen extends StatefulWidget {
  final Map<String, dynamic> resume;

  const ResumePreviewScreen({
    super.key,
    required this.resume,
  });

  @override
  State<ResumePreviewScreen> createState() => _ResumePreviewScreenState();
}

class _ResumePreviewScreenState extends State<ResumePreviewScreen> {
  static const Color _background = Color(0xFF050505);
  static const Color _surface = Color(0xFF0D0D0D);
  static const Color _border = Color(0xFF242424);
  static const Color _primaryText = Color(0xFFF5F5F5);
  static const Color _secondaryText = Color(0xFFA3A3A3);
  static const Color _accent = Color(0xFF22C55E);

  final PodProfileService _profileService = PodProfileService();

  bool _isSaving = false;
  bool _isSaved = false;
  bool _isExportingPdf = false;

  List<String> _stringList(dynamic value) {
    if (value is! List) return [];

    return value
        .map((item) => item.toString())
        .where((item) => item.trim().isNotEmpty)
        .toList();
  }

  List<Map<String, dynamic>> _mapList(dynamic value) {
    if (value is! List) return [];

    return value
        .whereType<Map>()
        .map(
          (item) => Map<String, dynamic>.from(item),
        )
        .toList();
  }

  Future<void> _saveResume() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final success = await _profileService.saveTailoredResume(
        widget.resume,
      );

      if (!mounted) return;

      setState(() {
        _isSaving = false;
        _isSaved = success;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Tailored resume saved to your Solid Pod.'
                : 'Failed to save resume to your Solid Pod.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error saving resume: $error',
          ),
        ),
      );
    }
  }

  Future<void> _exportPdf() async {
    setState(() {
      _isExportingPdf = true;
    });

    try {
      final resume = widget.resume;

      final skills = _stringList(resume['skills']);
      final experience = _mapList(resume['experience']);
      final projects = _mapList(resume['projects']);
      final education = _mapList(resume['education']);

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.symmetric(
            horizontal: 42,
            vertical: 38,
          ),
          build: (context) {
            return [
              pw.Text(
                resume['fullName']?.toString() ?? 'Unknown',
                style: pw.TextStyle(
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                resume['targetRole']?.toString() ?? '',
                style: const pw.TextStyle(
                  fontSize: 15,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Wrap(
                spacing: 14,
                runSpacing: 4,
                children: [
                  if ((resume['email'] ?? '').toString().trim().isNotEmpty)
                    pw.Text(
                      resume['email'].toString(),
                      style: const pw.TextStyle(
                        fontSize: 9.5,
                        color: PdfColors.grey700,
                      ),
                    ),
                  if ((resume['phone'] ?? '').toString().trim().isNotEmpty)
                    pw.Text(
                      resume['phone'].toString(),
                      style: const pw.TextStyle(
                        fontSize: 9.5,
                        color: PdfColors.grey700,
                      ),
                    ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Divider(
                color: PdfColors.grey500,
                thickness: 0.8,
              ),
              pw.SizedBox(height: 14),
              _pdfSectionTitle(
                'PROFESSIONAL SUMMARY',
              ),
              pw.Text(
                resume['professionalSummary']?.toString() ??
                    'No summary generated.',
                style: const pw.TextStyle(
                  fontSize: 10.5,
                  lineSpacing: 3.5,
                ),
              ),
              pw.SizedBox(height: 20),
              _pdfSectionTitle(
                'CORE SKILLS',
              ),
              pw.Wrap(
                spacing: 8,
                runSpacing: 6,
                children: skills
                    .map(
                      (skill) => pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.grey200,
                          borderRadius: pw.BorderRadius.circular(3),
                        ),
                        child: pw.Text(
                          skill,
                          style: const pw.TextStyle(
                            fontSize: 9.5,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              if (experience.isNotEmpty) ...[
                pw.SizedBox(height: 22),
                _pdfSectionTitle(
                  'PROFESSIONAL EXPERIENCE',
                ),
                ...experience.map(
                  (item) => _pdfExperienceItem(item),
                ),
              ],
              if (projects.isNotEmpty) ...[
                pw.SizedBox(height: 8),
                _pdfSectionTitle(
                  'PROJECTS',
                ),
                ...projects.map(
                  (item) => _pdfProjectItem(item),
                ),
              ],
              if (education.isNotEmpty) ...[
                pw.SizedBox(height: 8),
                _pdfSectionTitle(
                  'EDUCATION',
                ),
                ...education.map(
                  (item) => _pdfEducationItem(item),
                ),
              ],
            ];
          },
        ),
      );

      final safeName = (resume['fullName'] ?? 'resume')
          .toString()
          .toLowerCase()
          .replaceAll(
            RegExp(r'[^a-z0-9]+'),
            '_',
          )
          .replaceAll(
            RegExp(r'^_+|_+$'),
            '',
          );

      final safeRole = (resume['targetRole'] ?? 'tailored_resume')
          .toString()
          .toLowerCase()
          .replaceAll(
            RegExp(r'[^a-z0-9]+'),
            '_',
          )
          .replaceAll(
            RegExp(r'^_+|_+$'),
            '',
          );

      final fileName = '${safeName}_${safeRole}_resume.pdf';

      await Printing.layoutPdf(
        name: fileName,
        onLayout: (format) async {
          return pdf.save();
        },
      );
    } catch (error) {
      debugPrint(
        'PDF export error: $error',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to export PDF: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isExportingPdf = false;
        });
      }
    }
  }

  pw.Widget _pdfSectionTitle(
    String title,
  ) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.only(
        bottom: 5,
      ),
      margin: const pw.EdgeInsets.only(
        bottom: 10,
      ),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: PdfColors.grey500,
            width: 0.5,
          ),
        ),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 10.5,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget _pdfBullet(
    String text,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(
        bottom: 5,
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '• ',
            style: const pw.TextStyle(
              fontSize: 10,
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              text,
              style: const pw.TextStyle(
                fontSize: 10,
                lineSpacing: 2.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfExperienceItem(
    Map<String, dynamic> item,
  ) {
    final highlights = _stringList(item['highlights']);

    return pw.Container(
      margin: const pw.EdgeInsets.only(
        bottom: 16,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      item['role']?.toString() ?? '',
                      style: pw.TextStyle(
                        fontSize: 11.5,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    if ((item['company'] ?? '').toString().trim().isNotEmpty)
                      pw.Text(
                        item['company'].toString(),
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                  ],
                ),
              ),
              if ((item['dates'] ?? '').toString().trim().isNotEmpty)
                pw.Text(
                  item['dates'].toString(),
                  style: const pw.TextStyle(
                    fontSize: 9.5,
                    color: PdfColors.grey700,
                  ),
                ),
            ],
          ),
          pw.SizedBox(height: 6),
          ...highlights.map(
            (highlight) => _pdfBullet(highlight),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfProjectItem(
    Map<String, dynamic> item,
  ) {
    final highlights = _stringList(item['highlights']);

    return pw.Container(
      margin: const pw.EdgeInsets.only(
        bottom: 16,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            item['title']?.toString() ?? '',
            style: pw.TextStyle(
              fontSize: 11.5,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          if ((item['description'] ?? '').toString().trim().isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              item['description'].toString(),
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey700,
              ),
            ),
          ],
          pw.SizedBox(height: 6),
          ...highlights.map(
            (highlight) => _pdfBullet(highlight),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfEducationItem(
    Map<String, dynamic> item,
  ) {
    final details = [
      item['institution']?.toString() ?? '',
      item['location']?.toString() ?? '',
      item['dates']?.toString() ?? '',
    ]
        .where(
          (value) => value.trim().isNotEmpty,
        )
        .join(' • ');

    return pw.Container(
      margin: const pw.EdgeInsets.only(
        bottom: 12,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            item['qualification']?.toString() ?? '',
            style: pw.TextStyle(
              fontSize: 11.5,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          if (details.isNotEmpty) ...[
            pw.SizedBox(height: 3),
            pw.Text(
              details,
              style: const pw.TextStyle(
                fontSize: 9.8,
                color: PdfColors.grey700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resume = widget.resume;

    final skills = _stringList(resume['skills']);

    final experience = _mapList(resume['experience']);

    final projects = _mapList(resume['projects']);

    final education = _mapList(resume['education']);

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _primaryText,
        title: const Text(
          'Tailored Resume',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 900,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TAILORED RESUME',
                  style: TextStyle(
                    color: _accent,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  resume['fullName'] ?? 'Unknown',
                  style: const TextStyle(
                    color: _primaryText,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  resume['targetRole'] ?? '',
                  style: const TextStyle(
                    color: _secondaryText,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 18,
                  runSpacing: 8,
                  children: [
                    if ((resume['email'] ?? '').toString().trim().isNotEmpty)
                      Text(
                        resume['email'].toString(),
                        style: const TextStyle(
                          color: _secondaryText,
                          fontSize: 14,
                        ),
                      ),
                    if ((resume['phone'] ?? '').toString().trim().isNotEmpty)
                      Text(
                        resume['phone'].toString(),
                        style: const TextStyle(
                          color: _secondaryText,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 36),
                _section(
                  'PROFESSIONAL SUMMARY',
                  Text(
                    resume['professionalSummary'] ?? 'No summary generated.',
                    style: const TextStyle(
                      color: _primaryText,
                      fontSize: 17,
                      height: 1.6,
                    ),
                  ),
                ),
                _section(
                  'CORE SKILLS',
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: skills
                        .map(
                          (skill) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _background,
                              border: Border.all(
                                color: _border,
                              ),
                            ),
                            child: Text(
                              skill,
                              style: const TextStyle(
                                color: _primaryText,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                if (experience.isNotEmpty)
                  _section(
                    'PROFESSIONAL EXPERIENCE',
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: experience.map(
                        (item) {
                          final highlights = _stringList(
                            item['highlights'],
                          );

                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: 28,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['role']?.toString() ?? '',
                                            style: const TextStyle(
                                              color: _primaryText,
                                              fontSize: 19,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          if ((item['company'] ?? '')
                                              .toString()
                                              .trim()
                                              .isNotEmpty) ...[
                                            const SizedBox(
                                              height: 4,
                                            ),
                                            Text(
                                              item['company'].toString(),
                                              style: const TextStyle(
                                                color: _secondaryText,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    if ((item['dates'] ?? '')
                                        .toString()
                                        .trim()
                                        .isNotEmpty)
                                      Text(
                                        item['dates'].toString(),
                                        style: const TextStyle(
                                          color: _secondaryText,
                                          fontSize: 14,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 14,
                                ),
                                _list(
                                  highlights,
                                ),
                              ],
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                if (projects.isNotEmpty)
                  _section(
                    'PROJECTS',
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: projects.map(
                        (item) {
                          final highlights = _stringList(
                            item['highlights'],
                          );

                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: 26,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title']?.toString() ?? '',
                                  style: const TextStyle(
                                    color: _primaryText,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if ((item['description'] ?? '')
                                    .toString()
                                    .trim()
                                    .isNotEmpty) ...[
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    item['description'].toString(),
                                    style: const TextStyle(
                                      color: _secondaryText,
                                      fontSize: 15,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                                const SizedBox(
                                  height: 12,
                                ),
                                _list(
                                  highlights,
                                ),
                              ],
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                if (education.isNotEmpty)
                  _section(
                    'EDUCATION',
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: education.map(
                        (item) {
                          final details = [
                            item['institution']?.toString() ?? '',
                            item['location']?.toString() ?? '',
                            item['dates']?.toString() ?? '',
                          ]
                              .where(
                                (value) => value.trim().isNotEmpty,
                              )
                              .join(' • ');

                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: 18,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['qualification']?.toString() ?? '',
                                  style: const TextStyle(
                                    color: _primaryText,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (details.isNotEmpty) ...[
                                  const SizedBox(
                                    height: 6,
                                  ),
                                  Text(
                                    details,
                                    style: const TextStyle(
                                      color: _secondaryText,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: FilledButton.icon(
                    onPressed: _isSaving ? null : _saveResume,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : Icon(
                            _isSaved
                                ? Icons.check_circle
                                : Icons.cloud_upload_outlined,
                          ),
                    label: Text(
                      _isSaving
                          ? 'Saving to Solid Pod...'
                          : _isSaved
                              ? 'Saved to Solid Pod'
                              : 'Save Resume to Solid Pod',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.black,
                      disabledBackgroundColor: _accent,
                      disabledForegroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          4,
                        ),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: OutlinedButton.icon(
                    onPressed: _isExportingPdf ? null : _exportPdf,
                    icon: _isExportingPdf
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _accent,
                            ),
                          )
                        : const Icon(
                            Icons.picture_as_pdf_outlined,
                          ),
                    label: Text(
                      _isExportingPdf
                          ? 'Preparing PDF...'
                          : 'Download / Print PDF',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _accent,
                      side: const BorderSide(
                        color: _accent,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          4,
                        ),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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
                        'Your generated resume can be stored in your personal Solid Pod or exported as a PDF.',
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

  Widget _section(
    String title,
    Widget child,
  ) {
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

  Widget _list(
    List<String> items,
  ) {
    if (items.isEmpty) {
      return const Text(
        'No information available.',
        style: TextStyle(
          color: _secondaryText,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(
            bottom: 10,
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
    );
  }
}
