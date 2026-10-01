package dev.devinson.safeqr.feature.scanner

import dev.devinson.safeqr.domain.QrContent

sealed interface ScannerUiState {
    data object Ready : ScannerUiState

    data class Result(
        val content: QrContent,
    ) : ScannerUiState

    data class Error(
        val message: String,
    ) : ScannerUiState
}
