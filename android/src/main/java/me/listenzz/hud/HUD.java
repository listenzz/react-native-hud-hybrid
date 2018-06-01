package me.listenzz.hud;

import android.app.Activity;
import android.content.DialogInterface;
import android.graphics.Color;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.util.TypedValue;
import android.widget.ImageView;
import android.widget.TextView;

import com.kaopiz.kprogresshud.KProgressHUD;

public class HUD {

    public HUD(Activity context) {
        this.context = context;
    }

    Activity context;

    private final Handler handler = new Handler(Looper.getMainLooper());

    private KProgressHUD kProgressHUD;

    private int loadingCount;

    public void show(String text) {
        if (loadingCount == 0) {
            kProgressHUD = KProgressHUD.create(context)
                    .setStyle(KProgressHUD.Style.SPIN_INDETERMINATE)
                    .setGraceTime(HUDConfig.graceTime)
                    .setCancellable(new DialogInterface.OnCancelListener() {
                        @Override
                        public void onCancel(DialogInterface dialogInterface) {
                            forceHide();
                        }
                    });
            if (text != null) {
                kProgressHUD.setLabel(text);
            }
            kProgressHUD.show();
        }
        loadingCount++;
        Log.i("HUD", "show loading:"+ loadingCount);
    }

    public int hide() {
        loadingCount--;
        Log.i("HUD", "hide loading:"+ loadingCount);
        if (loadingCount <= 0) {
            loadingCount = 0;
            forceHide();
        }
        return loadingCount;
    }

    public void forceHide() {
        if (kProgressHUD != null) {
            kProgressHUD.dismiss();
            kProgressHUD = null;
            loadingCount = 0;
        }
    }

    public void text(String text) {
        KProgressHUD hud = KProgressHUD.create(context);
        configHUD(hud);
        TextView textView = new TextView(context);
        textView.setTextColor(Color.WHITE);
        textView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 16);
        textView.setText(text);
        hud.setCustomView(textView);
        hud.show();
        scheduleDismiss(hud);
    }


    public void info(String text) {
        KProgressHUD hud = KProgressHUD.create(context);
        configHUD(hud);
        ImageView imageView = new ImageView(context);
        imageView.setBackgroundResource(R.drawable.hud_info);
        hud.setCustomView(imageView);
        hud.setLabel(text);
        hud.show();
        scheduleDismiss(hud);
    }


    public void done(String text) {
        KProgressHUD hud = KProgressHUD.create(context);
        configHUD(hud);
        ImageView imageView = new ImageView(context);
        imageView.setBackgroundResource(R.drawable.hud_done);
        hud.setCustomView(imageView);
        hud.setLabel(text);
        hud.show();
        scheduleDismiss(hud);
    }


    public void error(String text) {
        KProgressHUD hud = KProgressHUD.create(context);
        configHUD(hud);
        ImageView imageView = new ImageView(context);
        imageView.setBackgroundResource(R.drawable.hud_error);
        hud.setCustomView(imageView);
        hud.setLabel(text);
        hud.show();
        scheduleDismiss(hud);
    }

    private void configHUD(KProgressHUD hud) {
        hud.setCornerRadius(HUDConfig.cornerRadius);
        hud.setBackgroundColor(HUDConfig.backgroundColor);
    }

    private void scheduleDismiss(final KProgressHUD hud) {
        if (handler.getLooper() == Looper.getMainLooper()) {
            handler.postDelayed(new Runnable() {
                @Override
                public void run() {
                    hud.dismiss();
                }
            }, HUDConfig.duration);
        }
    }

}
