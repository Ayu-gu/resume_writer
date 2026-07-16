/// ResumeWriter - orchestrate the primary login widget.
///
/// This file was generated from the `solidui` app template
/// (`dart run solidui:create`). Edit it freely to suit your app.

library;

import 'package:flutter/material.dart';

import 'package:solidui/solidui.dart';

import 'package:resume_writer/app_scaffold.dart';
import 'package:resume_writer/constants/app.dart';

// This widget is the root of the application. On startup it calls upon
// [SolidLogin] to connect to the user's Pod stored within their data vault on
// their chosen Solid server.

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return SolidThemeApp(
      // We can manually turn off the debug banner. It is turned off
      // automatically for a `flutter --release`.

      debugShowCheckedModeBanner: false,

      title: appTitle,

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF050806),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF22C55E),
          secondary: Color(0xFF16A34A),
          surface: Color(0xFF0D1510),
          surfaceContainerHighest: Color(0xFF152019),
          onPrimary: Colors.black,
          onSurface: Color(0xFFF4F7F4),
          onSurfaceVariant: Color(0xFF9FB0A3),
          outline: Color(0xFF243328),
          outlineVariant: Color(0xFF1C2A20),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF22C55E),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color.fromRGBO(216, 227, 219, 1),
          hintStyle: const TextStyle(
            color: Color(0xFF738078),
          ),
          labelStyle: const TextStyle(
            color: Color(0xFFA9B8AC),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFF263329),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFF22C55E),
              width: 2,
            ),
          ),
        ),
      ),

      home: SolidLogin(
        title: 'ResumeWriter\nYour Career Data. Your Control.',
        image: const AssetImage('assets/images/app_image.jpg'),
        logo: const AssetImage('assets/images/app_icon.png'),

        // The application folder created on the user's POD.

        appDirectory: appPodDirectory,

        // Solid app registration details. Update these in lib/constants/app.dart
        // to point at your own deployment; the clientId there must resolve to a
        // client profile document listing exactly these redirect URIs (see the
        // solid/ folder). See https://solidproject.org for more information.

        link: appLink,
        clientId: appClientId,
        redirectUris: appRedirectUris,
        postLogoutRedirectUris: appPostLogoutRedirectUris,
        child: appScaffold,
      ),
    );
  }
}
