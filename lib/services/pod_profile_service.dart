import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:solidpod/solidpod.dart';

class PodProfileService {
  static const String profilePath = 'resume_writer/career_profile.ttl';

  /// WRITE or UPDATE career profile in the user's Solid Pod
  Future<bool> saveCareerProfile({
    required String fullName,
    required String email,
    required String phone,
    required String summary,
    required String skills,
    required String experience,
    required String education,
  }) async {
    try {
      final profileData = {
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'summary': summary,
        'skills': skills,
        'experience': experience,
        'education': education,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      final jsonData = jsonEncode(profileData);

      await writePod(
        profilePath,
        jsonData,
        pathType: PathType.relativeToPod,
        overwrite: true,
      );

      debugPrint(
        '===== PROFILE SAVED TO POD =====',
      );
      debugPrint(jsonData);
      debugPrint(
        '================================',
      );

      return true;
    } catch (error, stackTrace) {
      debugPrint(
        'Failed to save profile to Pod: $error',
      );
      debugPrintStack(
        stackTrace: stackTrace,
      );

      return false;
    }
  }

  /// READ career profile from the user's Solid Pod
  Future<Map<String, dynamic>?> readCareerProfile() async {
    try {
      final result = await readPod(
        profilePath,
        pathType: PathType.relativeToPod,
      );

      debugPrint(
        '===== PROFILE READ FROM POD =====',
      );
      debugPrint(result);
      debugPrint(
        '=================================',
      );

      if (result.isEmpty) {
        return null;
      }

      return jsonDecode(result) as Map<String, dynamic>;
    } catch (error, stackTrace) {
      debugPrint(
        'Failed to read profile from Pod: $error',
      );
      debugPrintStack(
        stackTrace: stackTrace,
      );

      return null;
    }
  }

  /// SAVE a generated tailored resume to the user's Solid Pod
  ///
  /// Each resume gets a unique filename so previously generated
  /// resumes are not overwritten.
  Future<bool> saveTailoredResume(
    Map<String, dynamic> resume,
  ) async {
    try {
      final rawTargetRole =
          (resume['targetRole'] ?? 'tailored_resume').toString();

      final targetRole = rawTargetRole
          .toLowerCase()
          .replaceAll(
            RegExp(r'[^a-z0-9]+'),
            '_',
          )
          .replaceAll(
            RegExp(r'^_+|_+$'),
            '',
          );

      final safeTargetRole =
          targetRole.isEmpty ? 'tailored_resume' : targetRole;

      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final filePath = 'resume_writer/resumes/'
          '${safeTargetRole}_$timestamp.ttl';

      final resumeData = {
        ...resume,
        'savedAt': DateTime.now().toIso8601String(),
      };

      final jsonData = jsonEncode(resumeData);

      await writePod(
        filePath,
        jsonData,
        pathType: PathType.relativeToPod,
        overwrite: false,
      );

      debugPrint(
        '===== TAILORED RESUME SAVED TO POD =====',
      );
      debugPrint(
        'File: $filePath',
      );
      debugPrint(jsonData);
      debugPrint(
        '========================================',
      );

      return true;
    } catch (error, stackTrace) {
      debugPrint(
        'Failed to save tailored resume to Pod: $error',
      );
      debugPrintStack(
        stackTrace: stackTrace,
      );

      return false;
    }
  }
}
