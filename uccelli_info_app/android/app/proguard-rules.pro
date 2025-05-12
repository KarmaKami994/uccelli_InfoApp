# Add project specific Proguard rules here.
# By default, the flags in "proguard-android-optimize.txt" are used.
# This file is typically included via build.gradle using getDefaultProguardFile().
# Remove the -include line below if using getDefaultProguardFile in build.gradle.
#-include proguard-android-optimize.txt # Diese Zeile wurde entfernt, da die Standardregeln über build.gradle.kts eingebunden werden.

# To enable R8 tracing, add the following flag:
# -printconfiguration ./r8-configuration.txt

# Keep rules for androidx.window (to fix R8 errors like Missing class androidx.window...)
-keep class androidx.window.** { *; }
-keep class androidx.window.extensions.** { *; }
-keep class androidx.window.sidecar.** { *; }

# Add any other project-specific keep rules below this line if needed later.