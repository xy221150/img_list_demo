//
//  ImageTexture.m
//  Runner
//
//  Created by wxy on 2020/12/10.
//

#import "ImageTexture.h"
#import <SDWebImage/SDWebImageDownloader.h>
#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/SDImageCache.h>

@implementation ImageTexture{
    NSString* _url;
    CGFloat _width;
    CGFloat _height;
    CVPixelBufferRef _targetBuf;
    int64_t _textureid;
    FrameUpdateCallback _callback;
    SDWebImageManager *manager;
}

-(CVPixelBufferRef)copyPixelBuffer{
    CVBufferRetain(_targetBuf);
    return _targetBuf;
}

- (instancetype)initWithUrl:(NSString *)url width:(CGFloat) width height:(CGFloat) height frameUpdateCallback:(FrameUpdateCallback)callback{
    if (self = [super init]) {
        _url = url;
        _width = width;
        _height = height;
        _callback = callback;
    }
    [self initImage];
    return self;
}

-(void)initImage{
    manager = [SDWebImageManager sharedManager];
 
    [manager loadImageWithURL:[NSURL URLWithString:_url] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        if (image!=nil) {
            [self CVPixelBufferRefFromUiImage:image];
//            [[SDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];
            
            self->_callback();
         }
    }];
}

static OSType inputPixelFormat2(){
    return kCVPixelFormatType_32BGRA;
}

static uint32_t bitmapInfoWithPixelFormatType2(OSType inputPixelFormat, bool hasAlpha){
    
    if (inputPixelFormat == kCVPixelFormatType_32BGRA) {
        uint32_t bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host;
        if (!hasAlpha) {
            bitmapInfo = kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Host;
        }
        return bitmapInfo;
    }else if (inputPixelFormat == kCVPixelFormatType_32ARGB) {
        uint32_t bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Big;
        return bitmapInfo;
    }else{
        NSLog(@"不支持此格式");
        return 0;
    }
}

BOOL CGImageRefContainsAlpha2(CGImageRef imageRef) {
    if (!imageRef) {
        return NO;
    }
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
    BOOL hasAlpha = !(alphaInfo == kCGImageAlphaNone ||
                      alphaInfo == kCGImageAlphaNoneSkipFirst ||
                      alphaInfo == kCGImageAlphaNoneSkipLast);
    return hasAlpha;
}

- (void)CVPixelBufferRefFromUiImage:(UIImage *)img {
    CGSize size = img.size;
    CGImageRef image = [img CGImage];
    
    BOOL hasAlpha = CGImageRefContainsAlpha2(image);
    CFDictionaryRef empty = CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             empty, kCVPixelBufferIOSurfacePropertiesKey,
                             nil];
//    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, size.width, size.height, inputPixelFormat2(), (__bridge CFDictionaryRef) options, &_targetBuf);
    
    NSParameterAssert(status == kCVReturnSuccess && _targetBuf != NULL);
    
    CVPixelBufferLockBaseAddress(_targetBuf, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(_targetBuf);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    uint32_t bitmapInfo = bitmapInfoWithPixelFormatType2(inputPixelFormat2(), (bool)hasAlpha);
    
    CGContextRef context = CGBitmapContextCreate(pxdata, size.width, size.height, 8, CVPixelBufferGetBytesPerRow(_targetBuf), rgbColorSpace, bitmapInfo);
    NSParameterAssert(context);
    
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
    CVPixelBufferUnlockBaseAddress(_targetBuf, 0);
    
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
//    CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, _textureCache, _target, NULL, GL_TEXTURE_2D, GL_RGBA, size.width, size.height, GL_BGRA, GL_UNSIGNED_BYTE, 0, &_texture);
    
//    return pxbuffer;
}


@end
