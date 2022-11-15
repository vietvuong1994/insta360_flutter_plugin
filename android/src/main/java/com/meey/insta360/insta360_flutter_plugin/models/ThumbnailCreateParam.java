package com.meey.insta360.insta360_flutter_plugin.models;


import android.os.Build;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class ThumbnailCreateParam {
    public String[] urls;

    public ThumbnailCreateParam(Map<String, Object> creationParams){
        List<String> listUrls = new ArrayList<>();
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            Object dataUrls = creationParams.getOrDefault("urls", new String[0]);
            if(dataUrls instanceof ArrayList){
                ((ArrayList<?>) dataUrls).forEach((element) -> {
                    if(element instanceof String){
                        listUrls.add((String) element);
                    }
                });
            }
        }
        urls = listUrls.toArray(new String[0]);
    }
}
