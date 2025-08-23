package com.webicon

import android.content.Context
import android.content.SharedPreferences
import android.widget.ImageView
import com.bumptech.glide.Glide
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.annotations.ReactProp
import com.webicon.favicon.FaviconFetcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import androidx.core.content.edit

private fun getHostFromUrl(url: String): String {
  return try {
    val parsedUrl = java.net.URL(url)
    "${parsedUrl.protocol}://${parsedUrl.host}"
  } catch (e: Exception) {
    println("Invalid URL: $url")
    ""
  }
}

private fun getUrl(url: String, preferences: SharedPreferences): String {
  val iconPath = "https://t3.gstatic.com/faviconV2?client=SOCIAL&type=FAVICON&size=128&fallback_opts=TYPE,SIZE,URL&url=${getHostFromUrl(url)}"
  preferences.edit { putString(url, iconPath) }
  return iconPath
}

class MyImageView(context: Context) : androidx.appcompat.widget.AppCompatImageView(context) {
  private var icon: String? = null
  fun setIcon(icon: String) {
    this.icon = icon
    println("🐣 setIcon ${icon}")
    Glide.with(this)
      .load(icon)
      .into(this)
  }

  override fun onDetachedFromWindow() {
    super.onDetachedFromWindow()
    println("🐣 onDetachedFromWindow")
  }

  override fun onAttachedToWindow() {
    super.onAttachedToWindow()
    println("🐣 onAttachedToWindow")
    icon?.let {
      Glide.with(this)
        .load(icon)
        .into(this)
    }
  }
}

class WebIconViewManager(reactContext1: ReactApplicationContext) : SimpleViewManager<MyImageView>() {
  private val preferences = reactContext1.getSharedPreferences("favicon", Context.MODE_PRIVATE)
  override fun getName() = "WebIconView"

  override fun createViewInstance(reactContext: ThemedReactContext): MyImageView {
    return MyImageView(reactContext)
  }

  @ReactProp(name = "url")
  fun setUrl(view: MyImageView, url: String) {
    GlobalScope.launch {
      val icons = FaviconFetcher.getForURL(url, preferences)
      var icon: String? = icons.getOrNull(0)
      if (icon == null || icon.endsWith(".ico")) {
        icon = getUrl(url, preferences)
      }
      withContext(Dispatchers.Main) {
        view.setIcon(icon)
      }
    }
  }
}
