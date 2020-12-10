package com.wxy.flutterapp;

import android.graphics.SurfaceTexture;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.wxy.flutterapp.texture.ImageTexture;

import java.util.HashMap;
import java.util.Map;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.TextureRegistry;

public class MainActivity extends FlutterActivity implements MethodChannel.MethodCallHandler {

    private HashMap<String ,ImageTexture > fluttetrImageHashMap = new HashMap<>();
    private  TextureRegistry textures;
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        final MethodChannel channel = new MethodChannel(getFlutterView().getDartExecutor(), "ImageTexture");
        textures = getFlutterView().getPluginRegistry().registrarFor("ImageTexture").textures();
        channel.setMethodCallHandler(this);
    }


    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (call.method.equals("release")) {
            String textureId = call.argument("id");
            ImageTexture fluttetrImage =  fluttetrImageHashMap.get(textureId);
            fluttetrImage.dispose();
            fluttetrImageHashMap.remove(textureId);
        } else if (call.method.equals("load")) {
            TextureRegistry.SurfaceTextureEntry entry = textures.createSurfaceTexture();
            int width = call.argument("width");
            int height = call.argument("height");
            String url = call.argument("url");
            fluttetrImageHashMap.put(String.valueOf(entry.id()),new ImageTexture(this,url,width,height,entry));

            result.success(entry.id());
        }else {
            result.notImplemented();
        }
    }
}
