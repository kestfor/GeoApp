// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../style/colors.dart';
import 'stub.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color foregroundColor;

  const GoogleSignInButton({
    super.key,
    this.onTap,
    this.backgroundColor = Colors.black,
    this.foregroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        disabledBackgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        disabledForegroundColor: foregroundColor,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2,
      ),
      onPressed: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/google_logo.png', height: 24),
          const SizedBox(width: 12),
          const Text('Sign in with Google', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

/// Renders a SIGN IN button that calls `handleSignIn` onclick.
Widget buildSignInButton({HandleSignInFn? onPressed}) {
  return GoogleSignInButton(onTap: onPressed);
}
