package dev.devinson.safeqr.feature.scanner

import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.lifecycle.compose.collectAsStateWithLifecycle

@Composable
fun ScannerRoute(
    viewModel: ScannerViewModel,
    onScan: () -> Unit,
    onOpenUrl: (String) -> Unit,
) {
    val state by viewModel.state.collectAsStateWithLifecycle()

    ScannerScreen(
        state = state,
        onScan = onScan,
        onOpenUrl = onOpenUrl,
    )
}
