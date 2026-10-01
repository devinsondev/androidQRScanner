package dev.devinson.safeqr.domain

data class QrContent(
    val text: String,
    val safeWebUrl: String?,
    val host: String?,
)
