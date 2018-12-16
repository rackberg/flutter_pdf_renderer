package de.lrosenberg.flutterpdfrenderer;

import android.annotation.TargetApi;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.pdf.PdfRenderer;
import android.os.Build;
import android.os.ParcelFileDescriptor;
import android.util.Log;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.UUID;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * FlutterPdfRendererPlugin
 */
@TargetApi(Build.VERSION_CODES.LOLLIPOP)
public class FlutterPdfRendererPlugin implements MethodCallHandler {

    private PdfRenderer mPdfRenderer;
    private PdfRenderer.Page mCurrentPage;
    private ParcelFileDescriptor mFileDescriptor;
    private Registrar registrar;

    private FlutterPdfRendererPlugin(Registrar registrar) {
        this.registrar = registrar;
    }

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "rackberg.flutter_pdf_renderer");
        channel.setMethodCallHandler(new FlutterPdfRendererPlugin(registrar));
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (call.method.equals("renderPdf")) {
            try {
                String path = call.argument("path");
                int page = call.<Integer>argument("page");
                result.success(renderPdf(path, page));
            } catch (IOException e) {
                e.printStackTrace();
            }
        } else {
            result.notImplemented();
        }
    }

    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    private String renderPdf(String filePath, int page) throws IOException {
        openRenderer(registrar.context(), registrar.lookupKeyForAsset(filePath));
        Bitmap bitmap = createBitmapOfPage(page);
        closeRenderer();

        // Send bitmap to flutter
        assert bitmap != null;
        return saveBitmap(bitmap);
    }

    private void openRenderer(Context context, String fileName) throws IOException {
        File file = new File(context.getCacheDir(), generateRandomFilename() + ".pdf");
        Log.d("openRenderer", "created file: " + file);
        if (!file.exists()) {
            InputStream asset;
            try {
                asset = context.getAssets().open(fileName);
                FileOutputStream output = null;
                output = new FileOutputStream(file);
                final byte[] buffer = new byte[1024];
                int size;

                while ((size = asset.read(buffer)) != -1) {
                    output.write(buffer, 0, size);
                }
                asset.close();
                output.close();

            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        mFileDescriptor = ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY);
        if (mFileDescriptor != null) {
            mPdfRenderer = new PdfRenderer(mFileDescriptor);
        }
    }

    private Bitmap createBitmapOfPage(int index) {
        // Show the first page.
        if (mPdfRenderer.getPageCount() <= index) {
            return null;
        }

        // Make sure to close the current page before opening another one.
        if (null != mCurrentPage) {
            mCurrentPage.close();
        }

        mCurrentPage = mPdfRenderer.openPage(index);

        Bitmap bitmap = Bitmap.createBitmap(mCurrentPage.getWidth(), mCurrentPage.getHeight(),
                Bitmap.Config.ARGB_8888);

        // Now render the page onto the Bitmap.
        mCurrentPage.render(bitmap, null, null, PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY);

        if (null != mCurrentPage) {
            mCurrentPage.close();
            mCurrentPage = null;
        }

        return bitmap;
    }

    private void closeRenderer() throws IOException {
        mPdfRenderer.close();
        mFileDescriptor.close();
    }

    private String saveBitmap(Bitmap bitmap) throws IOException {
        File createdPdfBitmap = new File(registrar.context().getCacheDir(), generateRandomFilename() + ".png");
        FileOutputStream fOut = new FileOutputStream(createdPdfBitmap);
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, fOut);
        fOut.flush();
        fOut.close();

        return createdPdfBitmap.getAbsolutePath();
    }

    private String generateRandomFilename() {
        return UUID.randomUUID().toString().replaceAll("-", "");
    }
}
