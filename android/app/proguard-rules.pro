# Flutter / OkHttp optional dependencies — these classes are only present
# when the corresponding optional providers are on the classpath.
-dontwarn org.conscrypt.Conscrypt
-dontwarn org.conscrypt.OpenSSLProvider
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**

# Meta (Facebook) Audience Network mediation adapter — references Infer
# Nullsafe annotations that ship only as build-time annotations and are not
# present at runtime. Suppress the R8 missing-class errors for them.
-dontwarn com.facebook.infer.annotation.Nullsafe$Mode
-dontwarn com.facebook.infer.annotation.Nullsafe
-keep class com.facebook.ads.** { *; }
-dontwarn com.facebook.ads.**

# Google Mobile Ads (AdMob) + mediation
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.mediation.** { *; }
-dontwarn com.google.android.gms.ads.**
