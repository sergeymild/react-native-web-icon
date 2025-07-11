package com.webicon.favicon


import android.content.SharedPreferences
import android.graphics.Color
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.net.HttpURLConnection
import java.net.URL
import kotlin.math.absoluteValue
import androidx.core.content.edit

object FaviconFetcher {
    private const val USER_AGENT = "Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X)"

    suspend fun getForURL(url: String?, preferences: SharedPreferences): List<String> = withContext(Dispatchers.IO) {
        try {
            if (url == null) return@withContext emptyList()

            val baseUrl = URL(removeQueryAndFragment(url))
            preferences.getStringSet(baseUrl.toString(), null)?.let {
                println("readFromCache ${baseUrl} ${it}")
                return@withContext it.toList()
            }
            val connection = (baseUrl.openConnection() as HttpURLConnection).apply {
                setRequestProperty("User-Agent", USER_AGENT)
            }

            return@withContext connection.inputStream.use { input ->
                val data = input.readBytes()
                val icons = FavIconParser.FavIconParserImpl().favIcons(data, baseUrl)
                val bestIcon = icons
                    .sortedByDescending { it.size.first * it.size.second }
                    .firstOrNull { it.isAppleTouch() } ?: icons.firstOrNull()

                val nonNullIcons = listOfNotNull(bestIcon?.url)
                preferences.edit {
                    println("saveToCache $baseUrl $nonNullIcons")
                    putStringSet(baseUrl.toString(), nonNullIcons.toSet())
                }
                return@use nonNullIcons
            }
        } catch (e: Throwable) {
            return@withContext emptyList()
        }
    }

    private fun removeQueryAndFragment(url: String): String {
        val uri = URL(url)
        return URL(uri.protocol, uri.host, uri.port, uri.path).toString()
    }

    fun stableColorFrom(text: String): Int {
        val hash = text.fold(5381) { acc, c -> ((acc shl 5) + acc) + c.code }
        val hex = DefaultFaviconBackgroundColors[hash.absoluteValue % DefaultFaviconBackgroundColors.size]
        return Color.parseColor("#$hex")
    }

    private val DefaultFaviconBackgroundColors = listOf(
        "2e761a", "399320", "40a624", "57bd35", "70cf5b", "90e07f", "b1eea5", "881606",
        "aa1b08", "c21f09", "d92215", "ee4b36", "f67964", "ffa792", "025295", "0568ba",
        "0675d3", "0996f8", "2ea3ff", "61b4ff", "95cdff", "00736f", "01908b", "01a39d",
        "01bdad", "27d9d2", "58e7e6", "89f4f5", "c84510", "e35b0f", "f77100", "ff9216",
        "ffad2e", "ffc446", "ffdf81", "911a2e", "b7223b", "cf2743", "ea385e", "fa526e",
        "ff7a8d", "ffa7b3"
    )
}
