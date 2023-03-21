
#import "SimpleCameraCapturer.h"

#import <AVFoundation/AVFoundation.h>

#import "SimpleCameraCapturer/SimpleCameraCapturerOutputBufferDelegate.h"

@implementation SimpleCameraCapturer
{
    dispatch_queue_t _queue;
    AVCaptureSession* _session;
    AVCaptureDeviceInput* _input;
    AVCaptureVideoDataOutput* _output;
    SimpleCameraCapturerOutputBufferDelegate* _bufferDelegate;
    void (^_callback)(CMSampleBufferRef);
}

-(id)initWithOutputCallback:(void(^)(CMSampleBufferRef))callback
{
    self = [super init];
    if (nil == self) {
        return nil;
    }
    
    _queue = dispatch_queue_create("com.tsvb.camera-queue", NULL);
    _session = nil;
    _callback = callback;
    
    return self;
}

-(void)start
{
    dispatch_async(_queue, ^{
        if (nil == self->_session) {
            bool ok = [self setupCamera];
            if (!ok) {
                return;
            }
        }
        
        if (!self->_session.isRunning) {
            [self->_session startRunning];
        }
    });
}

-(void)stop
{
    dispatch_async(_queue, ^{
        if (nil == self->_session) {
            return;
        }
        
        if (self->_session.isRunning) {
            [self->_session stopRunning];
        }
    });
}

-(bool)setupCamera
{
    @autoreleasepool {
        AVCaptureSession* session = [AVCaptureSession new];
        [session beginConfiguration];
        session.sessionPreset = AVCaptureSessionPreset1280x720;
        
        AVCaptureDeviceType type = AVCaptureDeviceTypeBuiltInWideAngleCamera;
        AVMediaType mediaType = AVMediaTypeVideo;
        AVCaptureDevicePosition position = AVCaptureDevicePositionFront;
        AVCaptureDevice* device =
            [AVCaptureDevice defaultDeviceWithDeviceType:type
                                               mediaType:mediaType
                                                position:position];
        
        if (nil == device) {
            device = [AVCaptureDevice defaultDeviceWithMediaType:mediaType];
        }
        if (nil == device) {
            return false;
        }
        
        AVCaptureDeviceInput* input = [AVCaptureDeviceInput deviceInputWithDevice:device
                                                                            error:nil];
        if (nil == input) {
            return false;
        }
        
        if ([session canAddInput:input]) {
            [session addInput:input];
        }
        else {
            return false;
        }
        
        NSDictionary<NSString*, id>* settings = @{
            (__bridge NSString*)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)
		};
        
        AVCaptureVideoDataOutput* output = [AVCaptureVideoDataOutput new];
        output.videoSettings = settings;
        output.alwaysDiscardsLateVideoFrames = true;
        SimpleCameraCapturerOutputBufferDelegate* bufferDelegate =
            [[SimpleCameraCapturerOutputBufferDelegate alloc] initWithCallback:_callback];
        [output setSampleBufferDelegate:bufferDelegate queue:_queue];
        _bufferDelegate = bufferDelegate;
        
        if ([session canAddOutput:output]) {
            [session addOutput:output];
        }
        else {
            return false;
        }
        
        AVCaptureConnection* connection = [output connectionWithMediaType:mediaType];
        connection.videoOrientation = AVCaptureVideoOrientationPortrait;
        
        [session commitConfiguration];
        _session = session;
        _input = input;
        _output = output;
        return true;
    }
}

@end
