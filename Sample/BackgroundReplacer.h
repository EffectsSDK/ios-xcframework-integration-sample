#ifndef BackgroundReplacer_h
#define BackgroundReplacer_h

#import "PixelBufferWrap.h"

@interface BackgroundReplacer : NSObject

-(nullable PixelBufferWrap*)processPixelBuffer:(nonnull CVPixelBufferRef)pixelBuffer;

-(void)setBackgroundWithContentOfFile:(nullable NSString*)filePath;
-(void)resetBackgroundImage;

@end

#endif /* GLBackgroundReplacer_h */
