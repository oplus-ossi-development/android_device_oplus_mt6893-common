package org.lineageos.oppo.imsinit;

import android.content.ContentResolver;
import android.content.Context;
import android.database.ContentObserver;
import android.net.Uri;
import android.os.Handler;
import android.provider.Settings;
import android.util.Log;
import android.app.ActivityManager;

import com.android.ims.ImsManager;

public class AirplaneModeObserver extends ContentObserver {
    private static final String LOG_TAG = "ImsInit";
    private final Uri airplaneModeUri = Settings.Global.getUriFor(Settings.Global.AIRPLANE_MODE_ON);

    private Context mContext;

    public AirplaneModeObserver(Context context, Handler handler) {
        super(handler);
        mContext = context;
    }

    void register(Context context) {
        context.getContentResolver().registerContentObserver(airplaneModeUri, false, this);
    }

    @Override
    public void onChange(boolean selfChange, Uri uri) {
        super.onChange(selfChange, uri);
        if (airplaneModeUri.equals(uri)) {
            // Check if airplane mode is on
            boolean isAirplaneModeOn = Settings.Global.getInt(mContext.getContentResolver(), Settings.Global.AIRPLANE_MODE_ON, 0) != 0;

            Log.i(LOG_TAG, "Airplane mode state changed! [" + isAirplaneModeOn + "]");
            if (!isAirplaneModeOn) {
                restartIms(); // Kill ims, then it will restarting.
                ImsManager.setEnhanced4gLteModeSetting(mContext, true);
            }
        }
    }

    public void restartIms() {
        try {
            // Find and kill the com.mediatek.ims process
            ActivityManager activityManager = (ActivityManager) mContext.getSystemService(Context.ACTIVITY_SERVICE);
            for (ActivityManager.RunningAppProcessInfo processInfo : activityManager.getRunningAppProcesses()) {
                if (processInfo.processName.equals("com.mediatek.ims")) {
                    android.os.Process.killProcess(processInfo.pid);
                    break;
                }
            }
            Log.i(LOG_TAG, "Killed ims. VoLTE will re-enabled in moment.");
        } catch (Exception e) {
            Log.e(LOG_TAG, "Failed to kill ims.");
            e.printStackTrace();
        }
    }
}
