#import "FrameView.h"

#import <CoreImage/CoreImage.h>

@implementation FrameView

-(nullable id)init
{
	self = [super init];
	if (nil == self) {
		return nil;
	}
	
	self.contentMode = UIViewContentModeScaleAspectFit;
	return self;
}

-(void)setPixelBuffer:(CVPixelBufferRef)pixelBuffer
{
    CIImage* img = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    [super setImage:[UIImage imageWithCIImage:img]];
}

@end
