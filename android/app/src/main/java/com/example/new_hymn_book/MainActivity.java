package com.example.new_hymn_book;

import io.flutter.embedding.android.FlutterActivity;
import android.Manifest;
import android.accounts.Account;
import android.accounts.AccountManager;
import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Bundle;
import io.flutter.plugin.common.MethodChannel;

import android.widget.Toast;
import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import java.util.Objects;
import java.util.regex.Pattern;


public class MainActivity extends FlutterActivity {

    private static final String CHANNEL = "my_channel"; // Change to your channel name
    private final String[] PERMISSIONS = new String[]{
            Manifest.permission.INTERNET,
            Manifest.permission.READ_CONTACTS,
            Manifest.permission.GET_ACCOUNTS
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        new MethodChannel(Objects.requireNonNull(getFlutterEngine()).getDartExecutor().getBinaryMessenger(), CHANNEL).setMethodCallHandler(
                (call, result) -> {

                    switch (call.method) {
                        case "getGoogleAccounts":
                            String accounts = getGoogleAccounts();
                            result.success(accounts);
                            break;

                        default:
                            result.notImplemented();
                    }

                }
        );
    }

    private String getGoogleAccounts() {
        String email;
        Pattern gmailPattern = Pattern.compile("^[a-zA-Z0-9.-]+@gmail\\.com$");
//        Pattern gmailPattern = Patterns.EMAIL_ADDRESS;
        AccountManager accountManager = (AccountManager) getSystemService(ACCOUNT_SERVICE);
        Account[] accounts = accountManager.getAccounts();
        StringBuilder emails = new StringBuilder();
        int count = 0;
        for (Account account : accounts) {
            if (gmailPattern.matcher(account.name).matches()) {
                count += 1;
                email = account.name;
                if (count == 1){
                    emails = new StringBuilder(email);
                } else {
                    emails.append("\n").append(email);
                }
            }
        }
        if (emails.toString() == ""){
            return "No Account";
        } else {
            return emails.toString();
        }
    }
    private void getPermissions() {
        if (!hasPermissions(this, PERMISSIONS)) {
            ActivityCompat.requestPermissions(this, PERMISSIONS, 1);
        }
    }

    // Checks whether permissions have been granted
    private boolean hasPermissions(Context context, String... PERMISSIONS) {

        if (context != null && PERMISSIONS != null) {
            for (String permission : PERMISSIONS) {
                if (ActivityCompat.checkSelfPermission(context, permission) != PackageManager.PERMISSION_GRANTED) {
                    return false;
                }
            }
        }
        return true;
    }

    // Returns the responses from permission requests
    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);

        if (requestCode == 1) {
            int x = 0;
            String tempStr, comment;
            for (String s : PERMISSIONS) {
                int m = s.length();
                int y = "Manifest.permission".length();
                tempStr = s.substring(y, m);
                if (grantResults[x] == PackageManager.PERMISSION_GRANTED) {
                    comment = tempStr + " permission is granted";
                } else {
                    comment = tempStr + " permission is denied";
                }
                Toast.makeText(this, comment, Toast.LENGTH_LONG).show();
                x++;
            }
        }
    }



}
