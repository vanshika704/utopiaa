
package com.example.utopia

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Handle the deep link
        val intent: Intent = intent
        val data: Uri? = intent.data
        if (data != null && data.toString() == "utopia://emergency") {
            // Trigger emergency alert functionality here
            triggerEmergencyAlert()
        }
    }

    private fun triggerEmergencyAlert() {
        // Your logic to trigger the emergency alert
        // Example: show a notification, start an emergency service, etc.
    }
}
