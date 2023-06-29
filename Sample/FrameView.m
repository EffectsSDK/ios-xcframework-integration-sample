#import "FrameView.h"

#import <CoreImage/CoreImage.h>
#import <CoreMotion/CMMotionManager.h>

@implementation FrameView
{
    CMMotionManager* _motionManager;
}

-(nullable instancetype)init
{
    self = [super init];
    if (nil == self) {
        return nil;
    }
	
	[self initialize];
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];	
	[self initialize];
	return self;
}

-(void)setPixelBuffer:(CVPixelBufferRef)pixelBuffer
{
    size_t width = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
    CIImage* img = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    if (width > height) {
        img = [img imageByApplyingCGOrientation:[self rotateOrientation]];
    }
    [super setImage:[UIImage imageWithCIImage:img]];
}

-(CGImagePropertyOrientation)rotateOrientation
{
    CMAccelerometerData* accelerometerData = _motionManager.accelerometerData;
    if (nil == accelerometerData) {
        return kCGImagePropertyOrientationUp;
    }
	
    double x = accelerometerData.acceleration.x;
	
    if (x < 0) {
        return kCGImagePropertyOrientationRight;
    }
    return kCGImagePropertyOrientationLeft;
}

-(void)initialize
{
	self.contentMode = UIViewContentModeScaleAspectFit;
	
	_motionManager = [CMMotionManager new];
	if (_motionManager.accelerometerAvailable) {
		_motionManager.accelerometerUpdateInterval = 0.1;
		[_motionManager startAccelerometerUpdates];
	}
}

@end
