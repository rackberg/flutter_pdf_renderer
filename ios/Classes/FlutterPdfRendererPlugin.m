#import "FlutterPdfRendererPlugin.h"
#import <flutter_pdf_renderer/flutter_pdf_renderer-Swift.h>

@implementation FlutterPdfRendererPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterPdfRendererPlugin registerWithRegistrar:registrar];
}
@end
