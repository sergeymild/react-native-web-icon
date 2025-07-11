package com.webicon.favicon
import org.jsoup.Jsoup
import java.net.URL

class FavIconParser {


    class FavIconParserImpl {
        fun favIcons(htmlData: ByteArray, baseUrl: URL): List<Favicon> {
            val html = htmlData.toString(Charsets.UTF_8).ifEmpty {
                htmlData.toString(Charsets.ISO_8859_1)
            }

            val document = Jsoup.parse(html, baseUrl.toString())
            val links = document.head().select("link[rel~=icon]") ?: return emptyList()

            return links.mapNotNull { element ->
                val rel = element.attr("rel")
                val href = element.attr("href")
                val sizes = element.attr("sizes")

                if (href.isBlank()) return@mapNotNull null

                val type =
                    if (href.contains(".ico")) Favicon.FavIconType.FAV_ICO else Favicon.FavIconType.from(
                        rel
                    )
                val size = parseSize(sizes)
                val iconUrl = URL(baseUrl, href).toString()

                Favicon(iconUrl, size, type)
            }
        }

        private fun parseSize(sizes: String?): Pair<Int, Int> {
            val parts = sizes?.split("x") ?: return Pair(0, 0)
            return if (parts.size >= 2) {
                Pair(parts[0].toIntOrNull() ?: 0, parts[1].toIntOrNull() ?: 0)
            } else Pair(0, 0)
        }
    }
}
