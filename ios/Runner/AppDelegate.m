#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import "DuiaflutterextexturePresenter.h"


NSObject<FlutterTextureRegistry> *textures;
@implementation AppDelegate{
    FlutterViewController *vc;
    FlutterMethodChannel *channel;
    NSMutableDictionary<NSNumber *, DuiaflutterextexturePresenter *> *renders;
}

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
    renders = [[NSMutableDictionary alloc] init];
  // Override point for customization after application launch.
    vc = (FlutterViewController *)self.window.rootViewController;
    textures = [[vc registrarForPlugin:@"ImageTexture"] textures];
    [self setMethodHandel];

    
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

-(void)setMethodHandel{
    channel = [FlutterMethodChannel methodChannelWithName:@"ImageTexture" binaryMessenger:vc];
    [channel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
        if([call.method isEqualToString:@"load"]){
            NSString *imageStr = call.arguments[@"url"];
            Boolean asGif = [call.arguments[@"asGif"] boolValue];
            CGFloat width = [call.arguments[@"width"] floatValue]*[UIScreen mainScreen].scale;
            CGFloat height = [call.arguments[@"height"] floatValue]*[UIScreen mainScreen].scale;

            CGSize size = CGSizeMake(width, height);
            
            DuiaflutterextexturePresenter *render = [[DuiaflutterextexturePresenter alloc] initWithImageStr:imageStr size:size asGif:asGif];
            int64_t textureId = [textures registerTexture:render];

            render.updateBlock = ^{
                [textures textureFrameAvailable:textureId];
            };
            [renders setObject:render forKey:[NSString stringWithFormat:@"%@",@(textureId)]];
           
            result(@(textureId));
        } else if([call.method isEqualToString:@"release"]){
            if (call.arguments[@"id"]!=nil && ![call.arguments[@"id"] isKindOfClass:[NSNull class]]) {
                DuiaflutterextexturePresenter *render = [renders objectForKey:call.arguments[@"id"]];
                [renders removeObjectForKey:call.arguments[@"id"]];
                [render dispose];
                NSString *textureId =  call.arguments[@"id"];
            
                [textures unregisterTexture:@([call.arguments[@"id"] integerValue]).longValue];
            }
        }else {
          result(FlutterMethodNotImplemented);
        }
    }];
}

@end
