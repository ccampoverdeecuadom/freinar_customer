package com.gomarketdemo.user;

import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;

import io.flutter.app.FlutterApplication;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugins.firebasemessaging.FlutterFirebaseMessagingService;

public class ApplicationStatus extends FlutterApplication implements PluginRegistry.PluginRegistrantCallback {

    @Override
    public void onCreate() {
        super.onCreate();
        FirebaseOptions options = new FirebaseOptions.Builder()
                .setApplicationId("com.gomarketdemo.user") // Required for Analytics.
                .setProjectId("gomarketdemo") // Required for Firebase Installations.
                .setApiKey("AIzaSyB2kvOckQn8vJlqi8PPnbOzK5dCf-xg3eQ") // Required for Auth.
                .build();
        FirebaseApp.initializeApp(this,options,"Gomarket");
        FlutterFirebaseMessagingService.setPluginRegistrant(this);
    }

    @Override
    public void registerWith(PluginRegistry registry) {
        FirebaseCloudMessagingPluginRegistrant.registerWith(registry);
    }
}
