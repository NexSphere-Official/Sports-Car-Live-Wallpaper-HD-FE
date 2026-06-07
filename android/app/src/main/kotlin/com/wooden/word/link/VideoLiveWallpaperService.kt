package com.wooden.word.link

import android.media.MediaPlayer
import android.service.wallpaper.WallpaperService
import android.util.Log
import android.view.SurfaceHolder
import java.io.File

class VideoLiveWallpaperService : WallpaperService() {
  override fun onCreateEngine(): Engine = VideoEngine()

  inner class VideoEngine : Engine() {
    private var mediaPlayer: MediaPlayer? = null

    override fun onSurfaceCreated(holder: SurfaceHolder) {
      super.onSurfaceCreated(holder)
      initializePlayer(holder)
    }

    override fun onVisibilityChanged(visible: Boolean) {
      val player = mediaPlayer ?: return
      runCatching {
        if (visible) {
          player.start()
        } else {
          player.pause()
        }
      }.onFailure { error ->
        Log.e(TAG, "Failed to change player visibility", error)
      }
    }

    override fun onSurfaceDestroyed(holder: SurfaceHolder) {
      super.onSurfaceDestroyed(holder)
      releasePlayer()
    }

    override fun onDestroy() {
      releasePlayer()
      super.onDestroy()
    }

    private fun initializePlayer(holder: SurfaceHolder) {
      releasePlayer()

      val videoFile = File(filesDir, LIVE_WALLPAPER_FILE_NAME)
      if (!videoFile.exists()) return

      val player = MediaPlayer()
      try {
        player.setSurface(holder.surface)
        player.setDataSource(videoFile.absolutePath)
        player.isLooping = true
        player.setVolume(0f, 0f)
        player.setVideoScalingMode(MediaPlayer.VIDEO_SCALING_MODE_SCALE_TO_FIT_WITH_CROPPING)
        player.prepare()
        player.start()
        mediaPlayer = player
      } catch (error: Exception) {
        Log.e(TAG, "Failed to initialize live wallpaper player", error)
        runCatching { player.release() }
      }
    }

    private fun releasePlayer() {
      val player = mediaPlayer ?: return
      mediaPlayer = null
      runCatching { player.stop() }
      runCatching { player.release() }
    }
  }

  companion object {
    private const val TAG = "VideoLiveWallpaper"
    const val LIVE_WALLPAPER_FILE_NAME = "live_wallpaper.mp4"
  }
}
