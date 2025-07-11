package com.webicon.favicon

data class Favicon(
    val url: String,
    val size: Pair<Int, Int>,
    val type: FavIconType
) {
    enum class FavIconType {
        APPLE_TOUCH_ICON,
        APPLE_TOUCH_ICON_PRECOMPOSED,
        ICON,
        FAV_ICO,
        UNDEFINED;

        companion object {
            fun from(value: String): FavIconType = when (value.lowercase()) {
                "apple-touch-icon" -> APPLE_TOUCH_ICON
                "apple-touch-icon-precomposed" -> APPLE_TOUCH_ICON_PRECOMPOSED
                "icon", "shortcut icon" -> ICON
                else -> UNDEFINED
            }
        }
    }

    fun isAppleTouch(): Boolean {
        return type == FavIconType.APPLE_TOUCH_ICON || type == FavIconType.APPLE_TOUCH_ICON_PRECOMPOSED
    }
}
