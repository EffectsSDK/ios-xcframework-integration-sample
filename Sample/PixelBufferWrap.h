#ifndef PixelBufferWrap_h
#define PixelBufferWrap_h

#import <CoreVideo/CVPixelBuffer.h>

@interface PixelBufferWrap : NSObject

-(nullable id)initWithPixelBuffer:(CVPixelBufferRef _Nonnull)buffer;

+(nullable id)wrapPixelBuffer:(CVPixelBufferRef _Nonnull)buffer;

@property(nonatomic, readonly)CVPixelBufferRef _Nonnull buffer;

@end

#endif
