#ifndef SimpleCameraCapturer_h
#define SimpleCameraCapturer_h

#import <CoreMedia/CoreMedia.h>

@interface SimpleCameraCapturer : NSObject

-(nullable instancetype)initWithQueue:(nullable dispatch_queue_t)queue OutputCallback:(void(^ _Nonnull)(CMSampleBufferRef _Nonnull))callback;

-(void)start;
-(void)stop;

@end

#endif
