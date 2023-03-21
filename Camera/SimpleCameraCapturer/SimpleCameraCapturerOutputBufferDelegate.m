#import "SimpleCameraCapturerOutputBufferDelegate.h"

@implementation SimpleCameraCapturerOutputBufferDelegate
{
    void(^_callback)(CMSampleBufferRef);
}

-(id)initWithCallback:(void(^)(CMSampleBufferRef))callback
{
    self = [super init];
    if (self) {
     _callback = callback;
    }
    
    return self;
}

- (void)captureOutput:(AVCaptureOutput *)output
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    _callback(sampleBuffer);
}

- (void)captureOutput:(AVCaptureOutput *)output
  didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{ }

@end
