package dev.devinson.safeqr.domain

import java.net.URI
import java.util.Locale

class QrContentAnalyzer {
    fun analyze(rawValue: String): QrContent {
        val text = rawValue.trim()
        val uri = parseSafeWebUri(text)

        return QrContent(
            text = text,
            safeWebUrl = uri?.toASCIIString(),
            host = uri?.host,
        )
    }

    private fun parseSafeWebUri(value: String): URI? {
        if (value.isBlank() || value.length > MAX_URL_LENGTH) return null

        val uri = runCatching { URI(value) }.getOrNull() ?: return null
        val scheme = uri.scheme?.lowercase(Locale.ROOT) ?: return null

        if (scheme !in SAFE_SCHEMES) return null
        if (uri.host.isNullOrBlank()) return null
        if (uri.userInfo != null) return null

        return uri
    }

    private companion object {
        const val MAX_URL_LENGTH = 4_096
        val SAFE_SCHEMES = setOf("http", "https")
    }
}
