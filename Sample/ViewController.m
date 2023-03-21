#import "BackgroundReplacer.h"
#import "FrameView.h"
#import "SimpleCameraCapturer.h"

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
{
    SimpleCameraCapturer* _capturer;
    FrameView* _frameView;
    BackgroundReplacer* _replacer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
	_frameView = [[FrameView alloc] init];
	[super setView:_frameView];
	
	NSBundle* bundle = [NSBundle mainBundle];
	NSString* backgroundFilePath = [bundle pathForResource:@"background_image" ofType:@"jpg"];
	
	_replacer = [[BackgroundReplacer alloc] init];
	[_replacer setBackgroundWithContentOfFile:backgroundFilePath];
	
	FrameView* frameView = _frameView;
    dispatch_queue_t mainQ = dispatch_get_main_queue();
    _capturer = [[SimpleCameraCapturer alloc] initWithOutputCallback:^(CMSampleBufferRef buffer) {
        CVPixelBufferRef frame = CMSampleBufferGetImageBuffer(buffer);
        PixelBufferWrap* processed = [self->_replacer processPixelBuffer:frame];
		
        dispatch_async(mainQ, ^{
			[frameView setPixelBuffer:processed.buffer];
        });
    }];
    
    [_capturer start];
}

@end
