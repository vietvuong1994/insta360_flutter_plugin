package com.meey.insta360.insta360_flutter_plugin.glide;

import android.content.Context;

import androidx.annotation.NonNull;

import com.arashivision.sdkmedia.work.WorkWrapper;
import com.bumptech.glide.Glide;
import com.bumptech.glide.Registry;
import com.bumptech.glide.annotation.GlideModule;
import com.bumptech.glide.module.AppGlideModule;

import java.io.InputStream;

@GlideModule
public class MyGlideModule extends AppGlideModule {

    @Override
    public void registerComponents(@NonNull Context context, @NonNull Glide glide, @NonNull Registry registry) {
        super.registerComponents(context, glide, registry);
        registry.prepend(WorkWrapper.class, InputStream.class, new WorkModelLoaderFactory(context));
    }

}
