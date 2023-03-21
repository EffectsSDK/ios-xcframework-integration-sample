#ifndef SimpleCameraCapturer_h
#define SimpleCameraCapturer_h

#import <CoreMedia/CoreMedia.h>

@interface SimpleCameraCapturer : NSObject

-(id)initWithOutputCallback:(void(^)(CMSampleBufferRef))callback;

-(void)start;
-(void)stop;

@end

#endif
