package dev.devinson.safeqr.scanner

import android.app.Activity
import com.google.android.gms.mlkit.barcode.Barcode
import com.google.android.gms.mlkit.codescanner.GmsBarcodeScannerOptions
import com.google.android.gms.mlkit.codescanner.GmsBarcodeScanning

class GoogleQrScanner(activity: Activity) {
    private val scanner = GmsBarcodeScanning.getClient(
        activity,
        GmsBarcodeScannerOptions.Builder()
            .setBarcodeFormats(Barcode.FORMAT_QR_CODE)
            .build(),
    )

    fun start(
        onResult: (String) -> Unit,
        onCanceled: () -> Unit,
        onFailure: (Throwable) -> Unit,
    ) {
        scanner.startScan()
            .addOnSuccessListener { barcode ->
                val value = barcode.rawValue
                if (value == null) {
                    onFailure(IllegalStateException("QR code contains no readable text"))
                } else {
                    onResult(value)
                }
            }
            .addOnCanceledListener(onCanceled)
            .addOnFailureListener(onFailure)
    }
}
