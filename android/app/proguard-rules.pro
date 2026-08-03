# Prevent R8 / D8 Dexing crash on Firebase Auth & Kotlin metadata
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

-keep class com.android.tools.r8.** { *; }
-dontwarn com.android.tools.r8.**

-ignorewarnings
