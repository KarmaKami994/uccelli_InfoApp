# Add project specific Proguard rules here.
# By default, the flags in "proguard-android-optimize.txt" are used.
# You can remove the following line and add your own Proguard rules here.
-include proguard-android-optimize.txt

# To enable R8 tracing, add the following flag:
# -printconfiguration ./r8-configuration.txt

# Keep rules for androidx.window (to fix R8 errors like Missing class androidx.window...)
-keep class androidx.window.** { *; }
-keep class androidx.window.extensions.** { *; }
-keep class androidx.window.sidecar.** { *; }

# Add any other project-specific keep rules below this line if needed later.