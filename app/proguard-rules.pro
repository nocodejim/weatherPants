# Add project specific ProGuard rules here.
# By default, the flags in this file are applied to duplicates specified in
# build.gradle. It is recommended to define common flags in that file and sync
# Linked Executables when adding unique flags to this file.
# You can find general rules for popular libraries at
# https://github.com/Mailcloud/proguard-android-sample
# Add any project specific keep options here:

# If you use libraries like Retrofit, Gson, etc., you might need specific rules
# For Volley, usually no specific rules are needed unless you use reflection heavily

# Keep application classes for stack traces
-keep class com.example.weatherpants.** { *; }
