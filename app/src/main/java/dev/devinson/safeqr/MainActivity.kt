package dev.devinson.safeqr

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.viewModels
import dev.devinson.safeqr.feature.scanner.ScannerRoute
import dev.devinson.safeqr.feature.scanner.ScannerViewModel
import dev.devinson.safeqr.platform.QrTextActions
import dev.devinson.safeqr.scanner.GoogleQrScanner
import dev.devinson.safeqr.ui.SafeQrTheme

class MainActivity : ComponentActivity() {
    private val viewModel: ScannerViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        val scanner = GoogleQrScanner(this)
        val textActions = QrTextActions(this)

        setContent {
            SafeQrTheme {
                ScannerRoute(
                    viewModel = viewModel,
                    onScan = {
                        scanner.start(
                            onResult = viewModel::onQrRead,
                            onCanceled = {},
                            onFailure = { viewModel.onScanFailed() },
                        )
                    },
                    onOpenUrl = ::openUrl,
                    onCopy = textActions::copy,
                    onShare = textActions::share,
                )
            }
        }
    }

    private fun openUrl(url: String) {
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
            .addCategory(Intent.CATEGORY_BROWSABLE)

        startActivity(Intent.createChooser(intent, "Открыть ссылку"))
    }
}
