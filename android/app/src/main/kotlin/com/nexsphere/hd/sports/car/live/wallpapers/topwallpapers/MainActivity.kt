package com.nexsphere.hd.sports.car.live.wallpapers.topwallpapers

import android.app.WallpaperManager
import android.content.ComponentName
import android.content.Intent
import android.graphics.BitmapFactory
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
  private val ioExecutor: ExecutorService = Executors.newSingleThreadExecutor()
  private val mainHandler = Handler(Looper.getMainLooper())

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(
      flutterEngine.dartExecutor.binaryMessenger,
      WALLPAPER_CHANNEL,
    ).setMethodCallHandler { call, result ->
      when (call.method) {
        "setStaticWallpaper" -> {
          val filePath = call.argument<String>("filePath")
          val target = call.argument<String>("target")
          if (filePath.isNullOrBlank() || target.isNullOrBlank()) {
            result.error("INVALID_ARGUMENT", "filePath and target are required", null)
            return@setMethodCallHandler
          }
          runWallpaperTask(result, "SET_STATIC_WALLPAPER_FAILED") {
            setStaticWallpaper(filePath, target)
          }
        }

        "setLiveWallpaper" -> {
          val filePath = call.argument<String>("filePath")
          if (filePath.isNullOrBlank()) {
            result.error("INVALID_ARGUMENT", "filePath is required", null)
            return@setMethodCallHandler
          }
          ioExecutor.execute {
            val prepared = runCatching { prepareLiveWallpaper(filePath) }
            mainHandler.post {
              prepared.fold(
                onSuccess = { success ->
                  if (success) {
                    runCatching {
                      openLiveWallpaperPreview()
                      result.success(true)
                    }.onFailure { error ->
                      Log.e(TAG, "setLiveWallpaper failed", error)
                      result.error("SET_LIVE_WALLPAPER_FAILED", error.message, null)
                    }
                  } else {
                    result.success(false)
                  }
                },
                onFailure = { error ->
                  Log.e(TAG, "setLiveWallpaper failed", error)
                  result.error("SET_LIVE_WALLPAPER_FAILED", error.message, null)
                },
              )
            }
          }
        }

        else -> result.notImplemented()
      }
    }
  }

  override fun onDestroy() {
    ioExecutor.shutdown()
    super.onDestroy()
  }

  private fun runWallpaperTask(
    result: MethodChannel.Result,
    errorCode: String,
    task: () -> Boolean,
  ) {
    ioExecutor.execute {
      val taskResult = runCatching { task() }
      mainHandler.post {
        taskResult.fold(
          onSuccess = { result.success(it) },
          onFailure = { error ->
            Log.e(TAG, "$errorCode failed", error)
            result.error(errorCode, error.message, null)
          },
        )
      }
    }
  }

  private fun setStaticWallpaper(filePath: String, target: String): Boolean {
    validateTarget(target)
    val sourceFile = File(filePath)
    if (!sourceFile.exists()) return false

    val bitmap = BitmapFactory.decodeFile(sourceFile.absolutePath) ?: return false
    return try {
      val wallpaperManager = WallpaperManager.getInstance(applicationContext)
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
        wallpaperManager.setBitmap(bitmap, null, true, wallpaperFlags(target))
      } else {
        if (target == TARGET_LOCK) return false
        wallpaperManager.setBitmap(bitmap)
      }
      true
    } finally {
      bitmap.recycle()
    }
  }

  private fun prepareLiveWallpaper(filePath: String): Boolean {
    val sourceFile = File(filePath)
    if (!sourceFile.exists()) return false

    val targetFile = File(filesDir, VideoLiveWallpaperService.LIVE_WALLPAPER_FILE_NAME)
    copyFile(sourceFile, targetFile)
    return targetFile.exists() && targetFile.length() > 0
  }

  private fun openLiveWallpaperPreview() {
    val intent = Intent(WallpaperManager.ACTION_CHANGE_LIVE_WALLPAPER).apply {
      putExtra(
        WallpaperManager.EXTRA_LIVE_WALLPAPER_COMPONENT,
        ComponentName(this@MainActivity, VideoLiveWallpaperService::class.java),
      )
    }
    startActivity(intent)
  }

  private fun wallpaperFlags(target: String): Int =
    when (target) {
      TARGET_HOME -> WallpaperManager.FLAG_SYSTEM
      TARGET_LOCK -> WallpaperManager.FLAG_LOCK
      TARGET_BOTH -> WallpaperManager.FLAG_SYSTEM or WallpaperManager.FLAG_LOCK
      else -> throw IllegalArgumentException("Unknown wallpaper target: $target")
    }

  private fun validateTarget(target: String) {
    when (target) {
      TARGET_HOME, TARGET_LOCK, TARGET_BOTH -> Unit
      else -> throw IllegalArgumentException("Unknown wallpaper target: $target")
    }
  }

  private fun copyFile(from: File, to: File) {
    FileInputStream(from).use { input ->
      FileOutputStream(to).use { output ->
        input.copyTo(output)
      }
    }
  }

  companion object {
    private const val TAG = "MainActivity"
    private const val WALLPAPER_CHANNEL = "com.nexsphere.hd.sports.car.live.wallpapers.topwallpapers/wallpaper"
    private const val TARGET_HOME = "home"
    private const val TARGET_LOCK = "lock"
    private const val TARGET_BOTH = "both"
  }
}
