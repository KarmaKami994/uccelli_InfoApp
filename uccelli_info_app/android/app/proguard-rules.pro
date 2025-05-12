# Add project specific Proguard rules here.
# By default, the flags in "proguard-android-optimize.txt" are used.
# This file is typically included via build.gradle using getDefaultProguardFile().
# Remove the -include line below if using getDefaultProguardFile in build.gradle.
#-include proguard-android-optimize.txt # Diese Zeile wurde entfernt, da die Standardregeln über build.gradle.kts eingebunden werden.

# To enable R8 tracing, add the following flag:
# -printconfiguration ./r8-configuration.txt

# Keep rules for androidx.window and its sub-packages (to fix R8 errors like Missing class androidx.window...)
# Expanding rules based on specific missing classes observed in logs.
-keep class androidx.window.** { *; } # Allgemeine Regel (behalten)
-keep class androidx.window.core.** { *; } # explizit core
-keep class androidx.window.extensions.** { *; } # explizit extensions
-keep class androidx.window.extensions.area.** { *; } # explizit extensions.area (neu basierend auf Log)
-keep class androidx.window.extensions.embedding.** { *; } # explizit extensions.embedding (neu basierend auf Log)
-keep class androidx.window.layout.** { *; } # explizit layout
-keep class androidx.window.sidecar.** { *; } # explizit sidecar

# Add any other project-specific keep rules below this line if needed later.