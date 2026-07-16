/// ResumeWriter - the primary application scaffold.
///
/// This file was generated from the `solidui` app template
/// (`dart run solidui:create`). Edit it freely to suit your app.

library;

import 'package:flutter/material.dart';
import 'package:resume_writer/screens/browse_files.dart';
import 'package:solidui/solidui.dart';

import 'package:resume_writer/constants/app.dart';
import 'package:resume_writer/home.dart';
import 'package:resume_writer/screens/job_input_screen.dart';
import 'package:resume_writer/screens/profile_data_screen.dart';

final _scaffoldController = SolidScaffoldController();

const appScaffold = AppScaffold();

class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return SolidScaffold(
      controller: _scaffoldController,
      hideNavRail: false,
      enableProfile: true,
      onLogout: (context) => SolidAuthHandler.instance.handleLogout(context),

      // The navigation menu drives the side navigation rail (and the drawer on
      // narrow screens). Each entry exposes a top-level page of the app.

      menu: const [
        SolidMenuItem(
          icon: Icons.home_outlined,
          title: 'Home',
          tooltip: '''
      **Home**

      Return to the ResumeWriter dashboard.
    ''',
          child: Home(title: appTitle),
        ),
        SolidMenuItem(
          icon: Icons.description_outlined,
          title: 'New Resume',
          tooltip: '''
      **New Resume**

      Analyse a job description and create a tailored resume.
    ''',
          child: JobInputScreen(),
        ),
        SolidMenuItem(
          icon: Icons.person_outline,
          title: 'Profile Data',
          tooltip: '''
      **Profile Data**

      View the professional information available from your Solid Pod.
    ''',
          child: ProfileDataScreen(),
        ),
        SolidMenuItem(
          icon: Icons.folder_outlined,
          title: 'Pod Files',
          tooltip: '''
      **Pod Files**

      Browse all files and folders stored in your Solid Pod.
    ''',
          child: BrowseFiles(),
        ),
      ],
      appBar: SolidAppBarConfig(
        title: appTitle.split(' - ')[0],
        versionConfig: const SolidVersionConfig(
          changelogUrl: 'https://github.com/example/resume_writer/blob/dev/'
              'CHANGELOG.md',
          showUpdateButton: true,
          downloadUrl: 'https://solidcommunity.au/installers/',
        ),
        actions: const [],
      ),

      // The status bar runs along the bottom of the window, surfacing the
      // current server, login state and security key status.

      statusBar: const SolidStatusBarConfig(
        serverInfo: SolidServerInfo(serverUri: SolidConfig.defaultServerUrl),
        loginStatus: SolidLoginStatus(),
        securityKeyStatus: SolidSecurityKeyStatus(),
      ),
      aboutConfig: SolidAboutConfig(
        applicationName: appTitle.split(' - ')[0],
        applicationIcon: Image.asset(
          'assets/images/app_icon.png',
          width: 64,
          height: 64,
        ),
        applicationLegalese: '''

        © ResumeWriter

        ''',
        text: '''

        ResumeWriter is a file browser application that allows you to manage
        files on your personal online data store (Pod) hosted on a Solid
        server.

        Key features:

        📂 Browse and manage files on your Solid POD;

        📤 Upload files to your POD;

        📥 Download files from your POD;

        🔐 Security key management for encrypted data;

        🎨 Theme switching (light/dark/system);

        🧭 Responsive navigation (rail ↔ drawer).

        Built with [solidpod](https://pub.dev/packages/solidpod) and
        [solidui](https://pub.dev/packages/solidui) for the
        [Australian Solid Community](https://solidcommunity.au).

        ''',
      ),
      themeToggle: const SolidThemeToggleConfig(
        enabled: true,
        showInAppBarActions: true,
      ),
      inviteConfig: inviteOthersConfig,
      child: const Home(title: appTitle),
    );
  }
}
