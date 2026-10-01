package dev.devinson.safeqr.feature.scanner

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.QrCodeScanner
import androidx.compose.material3.Button
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.unit.dp
import dev.devinson.safeqr.domain.QrContent

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ScannerScreen(
    state: ScannerUiState,
    onScan: () -> Unit,
    onOpenUrl: (String) -> Unit,
) {
    Scaffold(
        topBar = {
            TopAppBar(title = { Text("QR Scanner") })
        },
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 20.dp, vertical = 12.dp),
            verticalArrangement = Arrangement.spacedBy(20.dp),
        ) {
            Text(
                "Сканер ничего не открывает автоматически. " +
                    "Сначала вы увидите содержимое QR-кода.",
            )

            Button(
                onClick = onScan,
                modifier = Modifier.fillMaxWidth(),
                contentPadding = PaddingValues(vertical = 14.dp),
            ) {
                Icon(
                    imageVector = Icons.Default.QrCodeScanner,
                    contentDescription = null,
                )
                Text(
                    text = "Сканировать QR",
                    modifier = Modifier.padding(start = 10.dp),
                )
            }

            when (state) {
                ScannerUiState.Ready -> Unit
                is ScannerUiState.Error -> ErrorContent(state.message)
                is ScannerUiState.Result -> ResultContent(
                    content = state.content,
                    onOpenUrl = onOpenUrl,
                )
            }
        }
    }
}

@Composable
private fun ResultContent(
    content: QrContent,
    onOpenUrl: (String) -> Unit,
) {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        Text(
            text = "Содержимое QR-кода",
            style = MaterialTheme.typography.titleMedium,
        )
        Text(
            text = content.text,
            fontFamily = FontFamily.Monospace,
        )

        val url = content.safeWebUrl
        if (url != null) {
            Text(
                text = "Ссылка: " + content.host,
                style = MaterialTheme.typography.bodyMedium,
            )
            TextButton(onClick = { onOpenUrl(url) }) {
                Text("Открыть ссылку")
            }
        } else {
            Text(
                text = "Безопасная http/https-ссылка не обнаружена.",
                style = MaterialTheme.typography.bodyMedium,
            )
        }
    }
}

@Composable
private fun ErrorContent(message: String) {
    Text(
        text = message,
        color = MaterialTheme.colorScheme.error,
    )
}
