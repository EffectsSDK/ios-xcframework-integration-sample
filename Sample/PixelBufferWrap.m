#import "PixelBufferWrap.h"

@implementation PixelBufferWrap
{
	CVPixelBufferRef _buffer;
}

-(nullable id)initWithPixelBuffer:(CVPixelBufferRef)buffer
{
	self = [super init];
	if (nil == self) {
		return nil;
	}
	
	_buffer = CVPixelBufferRetain(buffer);
	return self;
}

+(nullable id)wrapPixelBuffer:(CVPixelBufferRef)buffer
{
	return [[PixelBufferWrap alloc] initWithPixelBuffer:buffer];
}

-(void)dealloc
{
	CVPixelBufferRelease(_buffer);
}

-(nonnull CVPixelBufferRef)buffer
{
	return _buffer;
}

@end
