//
//  ImageTexture.h
//  Runner
//
//  Created by wxy on 2020/12/10.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
NS_ASSUME_NONNULL_BEGIN
typedef void(^FrameUpdateCallback)(void);
@interface ImageTexture : NSObject<FlutterTexture>
- (instancetype)initWithUrl:(NSString*)url width:(CGFloat) width height:(CGFloat) height frameUpdateCallback:(FrameUpdateCallback)callback;


@end

NS_ASSUME_NONNULL_END
