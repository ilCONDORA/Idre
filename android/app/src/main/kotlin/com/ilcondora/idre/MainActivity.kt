package com.ilcondora.idre

import android.os.Build
import android.os.Bundle
import android.os.SystemClock
import android.view.View
import android.view.ViewTreeObserver
import io.flutter.embedding.android.FlutterActivity

/**
 * The only Android screen of Idre: it hosts the Flutter UI.
 *
 * It makes the hand-off from the native splash screen to the Flutter splash invisible:
 * 1. Android removes its splash as soon as this Activity draws its first frame. At that moment Flutter is often still
 *    loading, so the user would see an empty window for a while: the "i" disappears and then appears again.
 *    Here the Activity does not draw anything until Flutter has drawn its first frame, so the native splash stays on
 *    screen until the Flutter splash (which starts with the same "i") is ready.
 * 2. On Android 12+ the native splash is removed at once, without its fade-out: the Flutter frame underneath is
 *    identical, so a fade would only add a flicker.
 */
class MainActivity : FlutterActivity() {
    /** `true` once Flutter has drawn its first frame. */
    private var isFlutterUiDisplayed = false

    override fun onCreate(savedInstanceState: Bundle?) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            splashScreen.setOnExitAnimationListener { splashScreenView -> splashScreenView.remove() }
        }
        super.onCreate(savedInstanceState)
        keepTheNativeSplashUntilFlutterIsDisplayed()
    }

    override fun onFlutterUiDisplayed() {
        super.onFlutterUiDisplayed()
        isFlutterUiDisplayed = true
    }

    /**
     * Skips every frame of this Activity until Flutter has drawn its first one.
     *
     * Returning `false` from `onPreDraw` cancels the frame and Android asks again at the next one. This is the pattern
     * Android documents to keep a splash screen on screen for longer.
     */
    private fun keepTheNativeSplashUntilFlutterIsDisplayed() {
        val contentView: View = findViewById(android.R.id.content)
        val waitStartTimeInMilliseconds: Long = SystemClock.uptimeMillis()

        contentView.viewTreeObserver.addOnPreDrawListener(
            object : ViewTreeObserver.OnPreDrawListener {
                override fun onPreDraw(): Boolean {
                    val waitedTimeInMilliseconds: Long = SystemClock.uptimeMillis() - waitStartTimeInMilliseconds
                    // Safety valve: if Flutter never draws (for example an error before runApp), show the app anyway.
                    val hasWaitedTooLong: Boolean = waitedTimeInMilliseconds > MAXIMUM_WAIT_FOR_FLUTTER_IN_MILLISECONDS
                    if (!isFlutterUiDisplayed && !hasWaitedTooLong) {
                        return false
                    }
                    contentView.viewTreeObserver.removeOnPreDrawListener(this)
                    return true
                }
            },
        )
    }

    private companion object {
        /** Longest time the native splash waits for Flutter (debug builds on an emulator can take a few seconds). */
        const val MAXIMUM_WAIT_FOR_FLUTTER_IN_MILLISECONDS: Long = 10_000
    }
}
