package dev.devinson.safeqr.domain

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class QrContentAnalyzerTest {
    private val analyzer = QrContentAnalyzer()

    @Test
    fun acceptsHttpsUrl() {
        val result = analyzer.analyze("https://example.com/path?q=1")

        assertEquals("example.com", result.host)
        assertEquals("https://example.com/path?q=1", result.safeWebUrl)
    }

    @Test
    fun rejectsJavascriptScheme() {
        val result = analyzer.analyze("javascript:alert(1)")

        assertNull(result.safeWebUrl)
    }

    @Test
    fun rejectsUrlWithUserInfo() {
        val result = analyzer.analyze("https://trusted.example@evil.example/path")

        assertNull(result.safeWebUrl)
    }

    @Test
    fun plainTextStaysVisible() {
        val result = analyzer.analyze("Wi-Fi password: hunter2")

        assertEquals("Wi-Fi password: hunter2", result.text)
        assertNull(result.safeWebUrl)
    }
}
