#import "BackgroundReplacer.h"

#import <TSVB/TSVB.h>

static void releasePixelBufferCallback(void* refCon, const void* baseAddr)
{
	(void)baseAddr;
	CFRelease((CFTypeRef)refCon);
}

static CVPixelBufferRef toCVPixelBuffer(id<TSVBFrame> frame, OSType format)
{
	id<TSVBLockedFrameData> lockedMemory = [frame lock:TSVBFrameLockRead];
	if (nil == lockedMemory) {
		return NULL;
	}
	
	CFTypeRef cfLockedMemory = CFBridgingRetain(lockedMemory);

	CVPixelBufferRef result = NULL;
	CVReturn err = CVPixelBufferCreateWithBytes(
		kCFAllocatorDefault,
		frame.width,
		frame.height,
		format,
		[lockedMemory dataPointerOfPlanar:0],
		[lockedMemory bytesPerLineOfPlanar:0],
		&releasePixelBufferCallback,
		(void*)cfLockedMemory,
		NULL,
		&result
	);
	
	if (kCVReturnSuccess == err) {
		return result;
	}
	
	CFRelease(cfLockedMemory);
	return NULL;
}

@implementation BackgroundReplacer
{
	id<TSVBFrameFactory> _frameFactory;
	id<TSVBPipeline> _pipeline;
	id<TSVBReplacementController> _backgroundController;
}

-(nullable id)init
{
	self = [super init];
	if (nil == self) {
		return nil;
	}
	
	TSVBSDKFactory* sdkFactory = [TSVBSDKFactory new];
	if (nil == sdkFactory) {
		return nil;
	}
	
	_frameFactory = [sdkFactory newFrameFactory];
	if (nil == _frameFactory) {
		return nil;
	}
	
	_pipeline = [sdkFactory newPipeline];
	if (nil == _pipeline) {
		return nil;
	}
	
	id<TSVBPipelineConfiguration> configuration = [_pipeline copyConfiguration];
	configuration.backend = TSVBBackendGPU;
	
	id<TSVBReplacementController> controller = nil;
	enum TSVBPipelineError error = [_pipeline setConfiguration:configuration];
	if (TSVBPipelineErrorOk == error) {
		error = [_pipeline enableReplaceBackground:&controller];
	}
	
	if (TSVBPipelineErrorOk != error) {
		configuration.backend = TSVBBackendCPU;
		error = [_pipeline setConfiguration:configuration];
		if (TSVBPipelineErrorOk == error) {
			error = [_pipeline enableReplaceBackground:&controller];
		}
	}
	
	if (TSVBPipelineErrorOk != error) {
		return nil;
	}
	_backgroundController = controller;
	
	return self;
}

-(nullable PixelBufferWrap*)processPixelBuffer:(nonnull CVPixelBufferRef)pixelBuffer
{
	OSType cvFormat = CVPixelBufferGetPixelFormatType(pixelBuffer);
	bool supportedFormat =
		(kCVPixelFormatType_32BGRA == cvFormat) ||
		(kCVPixelFormatType_32RGBA == cvFormat);
	if (!supportedFormat) {
		return nil;
	}
	enum TSVBFrameFormat format = (kCVPixelFormatType_32BGRA == cvFormat)?
		TSVBFrameFormatBgra32 : TSVBFrameFormatRgba32;
	
	CVReturn err = CVPixelBufferLockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
	if (kCVReturnSuccess != err) {
		return nil;
	}
	
	size_t width = CVPixelBufferGetWidth(pixelBuffer);
	size_t height = CVPixelBufferGetHeight(pixelBuffer);
	size_t stride = CVPixelBufferGetBytesPerRow(pixelBuffer);
	void* srcData = CVPixelBufferGetBaseAddress(pixelBuffer);
	if (NULL == srcData) {
		CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
		return nil;
	}
	
	id<TSVBFrame> input =
	[_frameFactory newFrameWithFormat:format
								 data:srcData
						 bytesPerLine:(unsigned int)stride
								width:(unsigned int)width
							   height:(unsigned int)height
							 makeCopy:false];
	if (nil == input) {
		CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
		return nil;
	}
	
	id<TSVBFrame> resultFrame = [_pipeline process:input error:NULL];
	CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
	if (nil == resultFrame) {
		return nil;
	}
	
	CVPixelBufferRef resultPixelBuffer = toCVPixelBuffer(resultFrame, cvFormat);
	if (NULL == resultPixelBuffer) {
		return nil;
	}
	
	PixelBufferWrap* result = [PixelBufferWrap wrapPixelBuffer:resultPixelBuffer];
	CVPixelBufferRelease(resultPixelBuffer);
	
	return result;
}

-(void)setBackgroundWithContentOfFile:(nullable NSString*)filePath
{
	id<TSVBFrame> background = [_frameFactory imageWithContentOfFile:filePath];
	if (nil != background) {
		_backgroundController.background = background;
	}
}

-(void)resetBackgroundImage
{
	_backgroundController.background = nil;
}

@end
