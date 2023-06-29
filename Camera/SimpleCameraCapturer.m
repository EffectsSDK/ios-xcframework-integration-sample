
#import "SimpleCameraCapturer.h"

#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CMMotionManager.h>

#import "SimpleCameraCapturer/SimpleCameraCapturerOutputBufferDelegate.h"

@implementation SimpleCameraCapturer
{
    dispatch_queue_t _queue;
    AVCaptureSession* _session;
    AVCaptureDeviceInput* _input;
    AVCaptureVideoDataOutput* _output;
    AVCaptureConnection* _connection;
    SimpleCameraCapturerOutputBufferDelegate* _bufferDelegate;
    void (^_callback)(CMSampleBufferRef);
	
    NSOperationQueue* _operationQueue;
    CMMotionManager* _motionManager;
    AVCaptureVideoOrientation _currentOrientation;
}

-(id)initWithQueue:(dispatch_queue_t)queue OutputCallback:(void(^)(CMSampleBufferRef))callback
{
    self = [super init];
    if (nil == self) {
        return nil;
    }
	
	_queue = queue;
	if (NULL == _queue) {
		_queue = dispatch_queue_create("com.tsvb.simple-camera-capturer", NULL);
	}
	
    _session = nil;
    _callback = callback;
	
    _operationQueue = [NSOperationQueue new];
    _operationQueue.underlyingQueue = _queue;
    _motionManager = [CMMotionManager new];
    _currentOrientation = AVCaptureVideoOrientationPortrait;
	
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
	
    if(!_motionManager.isAccelerometerAvailable) {
        return;
    }
	
    _motionManager.accelerometerUpdateInterval = 0.1;
    [_motionManager startAccelerometerUpdatesToQueue:_operationQueue
										 withHandler:^(
            CMAccelerometerData* _Nullable accelerometerData, NSError* _Nullable error) {
			
        if (nil == accelerometerData){
            return;
        }
			
        double x = accelerometerData.acceleration.x;
        double y = accelerometerData.acceleration.y;
		
        AVCaptureVideoOrientation orientation = self->_currentOrientation;
        if (x >= 0.75) {
            orientation = AVCaptureVideoOrientationLandscapeLeft;
        }
        else if(x <= -0.75) {
            orientation = AVCaptureVideoOrientationLandscapeRight;
        }
        else if (y <= -0.75) {
            orientation = AVCaptureVideoOrientationPortrait;
        }
        else if (y >= 0.75) {
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
        }
			
        if (orientation != self->_currentOrientation) {
            self->_currentOrientation = orientation;
            if (nil != self->_connection) {
                [self->_session beginConfiguration];
                self->_connection.videoOrientation = orientation;
                [self->_session commitConfiguration];
            }
        }
    }];
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
	
    [_motionManager stopAccelerometerUpdates];
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
        
        AVCaptureDeviceInput* input = [AVCaptureDeviceInput
									   deviceInputWithDevice:device
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
        
        _connection = [output connectionWithMediaType:mediaType];
        _connection.videoOrientation = _currentOrientation;
        _connection.videoMirrored = YES;
        
        [session commitConfiguration];
        _session = session;
        _input = input;
        _output = output;
        return true;
    }
}

@end
