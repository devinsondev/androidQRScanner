package dev.devinson.safeqr.feature.scanner

import androidx.lifecycle.ViewModel
import dev.devinson.safeqr.domain.QrContentAnalyzer
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

class ScannerViewModel(
    private val analyzer: QrContentAnalyzer = QrContentAnalyzer(),
) : ViewModel() {
    private val _state = MutableStateFlow<ScannerUiState>(ScannerUiState.Ready)
    val state: StateFlow<ScannerUiState> = _state.asStateFlow()

    fun onQrRead(rawValue: String) {
        _state.value = ScannerUiState.Result(analyzer.analyze(rawValue))
    }

    fun onScanFailed() {
        _state.value = ScannerUiState.Error(
            "Не удалось прочитать QR-код. Попробуйте ещё раз.",
        )
    }
}
