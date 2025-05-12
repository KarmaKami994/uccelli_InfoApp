# Add project specific Proguard rules here.
# By default, the flags in "proguard-android-optimize.txt" are used.
# This file is typically included via build.gradle using getDefaultProguardFile().
# Remove the -include line below if using getDefaultProguardFile in build.gradle.
#-include proguard-android-optimize.txt # Diese Zeile wurde entfernt, da die Standardregeln über build.gradle.kts eingebunden werden.

# To enable R8 tracing, add the following flag:
# -printconfiguration ./r8-configuration.txt

# SEHR BREITE Keep rules for androidx.window (Versuch, wenn spezifische Regeln fehlschlagen)
# Dies versucht, alle Klassen, Felder, Methoden und Konstruktoren im androidx.window Paket und Unterpaketen zu behalten.
# Verwende dies, wenn die spezifischeren Regeln nicht funktioniert haben. Dies könnte die APK-Größe erhöhen.
-keep class androidx.window.** { *; }
-keep class androidx.window.** {
  <fields>;
  <methods>;
  <init>();
}

# Add dontwarn rules for androidx.window packages
# This tells R8 to ignore warnings about missing references in these packages.
# Use this as a diagnostic step if keep rules don't resolve the compilation failure.
-dontwarn androidx.window.**
-dontwarn androidx.window.core.**
-dontwarn androidx.window.extensions.**
-dontwarn androidx.window.extensions.area.**
-dontwarn androidx.window.extensions.embedding.**
-dontwarn androidx.window.layout.**
-dontwarn androidx.window.sidecar.**

# Add any other project-specific keep rules below this line if needed later.