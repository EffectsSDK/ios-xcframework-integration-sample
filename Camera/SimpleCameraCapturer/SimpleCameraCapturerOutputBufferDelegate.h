#ifndef SimpleCameraCapturerOutputBufferDelegate_h
#define SimpleCameraCapturerOutputBufferDelegate_h

#import <AVFoundation/AVFoundation.h>

@interface SimpleCameraCapturerOutputBufferDelegate :
    NSObject<AVCaptureVideoDataOutputSampleBufferDelegate>

-(id)initWithCallback:(void(^)(CMSampleBufferRef))callback;

@end


#endif /* SimpleCameraCapturerOutputBufferDelegate_h */
