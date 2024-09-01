package org.lineageos.oppo.imsinit;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import org.lineageos.oppo.imsinit.AirplaneModeObserver;

public class BootCompletedReceiver extends BroadcastReceiver {
    private static final String LOG_TAG = "ImsInit";

    @Override
    public void onReceive(final Context context, Intent intent) {
        Log.i(LOG_TAG, "onBoot");

	Handler handler = new Handler(Looper.getMainLooper());
        AirplaneModeObserver observer = new AirplaneModeObserver(context, handler);
        observer.register(context);
    }
}
