#!/bin/bash
NEW_NAME="Frontend"
NEW_BUNDLE="com.example.frontend"

# 앱 이름 변경
flutter pub global run rename setAppName --value "$NEW_NAME"

# BundleId 변경
flutter pub global run rename setBundleId --value "$NEW_BUNDLE"

# pubspec.yaml name 변경
sed -i '' "s/^name: .*/name: $NEW_NAME/" pubspec.yaml
