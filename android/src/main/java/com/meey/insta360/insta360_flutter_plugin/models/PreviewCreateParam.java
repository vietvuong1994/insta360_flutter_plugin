package com.meey.insta360.insta360_flutter_plugin.models;


import android.os.Build;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

public class PreviewCreateParam {
    public String[] deleteUrls;
    public String[] urls;

    public PreviewCreateParam(Map<String, Object> creationParams){
        List<String> listUrls = new ArrayList<>();
        List<String> listDeleteUrls = new ArrayList<>();

        this.deleteUrls = new String[0];
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            Object dataUrls = creationParams.getOrDefault("urls", new String[0]);
            if(dataUrls instanceof ArrayList){
                ((ArrayList<?>) dataUrls).forEach((element) -> {
                    if(element instanceof String){
                        listUrls.add((String) element);
                    }
                });
            }

            Object dataDeleteUrls = creationParams.getOrDefault("deleteUrls", new String[0]);
            if(dataDeleteUrls instanceof ArrayList){
                ((ArrayList<?>) dataDeleteUrls).forEach((element) -> {
                    if(element instanceof String){
                        listDeleteUrls.add((String) element);
                    }
                });
            }
        }
        urls = listUrls.toArray(new String[0]);
        deleteUrls = listDeleteUrls.toArray(new String[0]);
    }
}
