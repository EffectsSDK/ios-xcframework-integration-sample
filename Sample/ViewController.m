#import "ViewController.h"

#import "FrameView.h"
#import "SimpleCameraCapturer.h"
#import "Metrics.h"

#import <TSVB/TSVB.h>

@interface ViewController ()

@end

@implementation ViewController
{
    SimpleCameraCapturer* _capturer;
	id<TSVBFrameFactory> _frameFactory;
	id<TSVBPipeline> _pipeline;
	Metrics* _metrics;
	dispatch_queue_t _pipelineQueue;
	dispatch_queue_t _controlQueue;
	
	bool _blurEnabled;
	bool _replaceEnabled;
	bool _denoiseEnabled;
	bool _beautificationEnabled;
	bool _colorCorrectionEnabled;
	bool _smartZoomEnabled;
	
	FrameView* _frameView;
	UILabel* _fpsLabel;
	UILabel* _timeLabel;
	NSTimer* _updateLabelTimer;
	
	UIButton* _blurButton;
	UIButton* _replaceButton;
	UIButton* _denoiseButton;
	UIButton* _beautificationButton;
	UIButton* _colorCorrectionButton;
	UIButton* _smartZoomButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
	TSVBSDKFactory* sdkFactory = [TSVBSDKFactory new];
	_frameFactory = [sdkFactory newFrameFactory];
	_pipeline = [sdkFactory newPipeline];
	_metrics = [Metrics new];
	
	_frameView = [[FrameView alloc] initWithFrame:CGRectZero];
	UIView* rootView = [[UIView alloc] initWithFrame:CGRectZero];
	[rootView addSubview:_frameView];
	_frameView.autoresizingMask =
		UIViewAutoresizingFlexibleWidth |
		UIViewAutoresizingFlexibleHeight;
	[rootView addSubview:[self newViewWithButtons]];

	_timeLabel = [self newInfoLabel];
	[rootView addSubview:_timeLabel];
	
	_fpsLabel = [self newInfoLabel];
	[rootView addSubview:_fpsLabel];
	
 	[self setView:rootView];
	
	FrameView* frameView = _frameView;
	_controlQueue = dispatch_queue_create("com.tsvb.videofilter-control", NULL);
	_pipelineQueue = dispatch_queue_create("com.tsvb.camera-pipeline", NULL);
    dispatch_queue_t mainQ = dispatch_get_main_queue();
	_capturer = [[SimpleCameraCapturer alloc] initWithQueue:_pipelineQueue OutputCallback:^(CMSampleBufferRef buffer) {
		CVPixelBufferRef capturedFrame = CMSampleBufferGetImageBuffer(buffer);
		NSDate* startTime = [NSDate now];
		id<TSVBFrame> processedFrame = nil;
		enum TSVBPipelineError error = TSVBPipelineErrorOk;
		@synchronized (self->_pipeline) {
			processedFrame = [self->_pipeline processCVPixelBuffer:capturedFrame error:&error];
		}
		NSDate* endTime = [NSDate now];
		NSDateInterval* interval = [[NSDateInterval alloc] initWithStartDate:startTime endDate:endTime];
		if (nil != processedFrame) {
			dispatch_async(mainQ, ^{
				[self->_metrics didProcessFrameForInterval:interval];
				[self->_metrics didCameraFrame:endTime];
				[frameView setPixelBuffer:[processedFrame toCVPixelBuffer]];
			});
		}
		else if (TSVBPipelineErrorNoFeaturesEnabled == error) {
			CVPixelBufferRetain(capturedFrame);
			dispatch_async(mainQ, ^{
				[self->_metrics didCameraFrame:endTime];
				[frameView setPixelBuffer:capturedFrame];
				CVPixelBufferRelease(capturedFrame);
			});
		}
	}];
	[self dispatchControlActionWithDisabledControl:_replaceButton action:^{
		[self enableReplaceBackground];
		[self setFeatureButtonStateAsync:self->_replaceButton featureEnabled:self->_replaceEnabled];
	}];
    [_capturer start];
	
	_updateLabelTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 repeats:YES block:^(NSTimer* timer){
		[self updateTimeAndFPSLabels];
	}];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

-(UIButton*)newButtonWithTitle:(NSString*)title action:(SEL)action
{
	UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
	[button setTitle:title forState:UIControlStateNormal];
	button.titleLabel.font = [UIFont boldSystemFontOfSize:24];
	[button setTitleColor:[self standardButtonColor] forState:UIControlStateNormal];
	[button setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
	[button addTarget:self action:action forControlEvents:UIControlEventTouchDown];
	button.contentEdgeInsets = UIEdgeInsetsMake(20, 8, 20, 8);
	
	return button;
}

-(UILabel*)newInfoLabel
{
	UILabel* label = [[UILabel alloc] initWithFrame:CGRectZero];
	label.textColor = [UIColor whiteColor];
	label.textAlignment = NSTextAlignmentCenter;
	label.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3f];
	label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
	return label;
}

-(UIScrollView*)newViewWithButtons
{
	_blurButton = [self newButtonWithTitle:@"Blur" action:@selector(toggleBlurBackground)];
	_replaceButton = [self newButtonWithTitle:@"Replacement" action:@selector(toggleReplaceBackground)];
	_denoiseButton = [self newButtonWithTitle:@"Denoise" action:@selector(toggleDenoiseBackground)];
	_beautificationButton = [self newButtonWithTitle:@"Beautification" action:@selector(toggleBeautification)];
	_colorCorrectionButton = [self newButtonWithTitle:@"Color Correction" action:@selector(toggleColorCorrecton)];
	_smartZoomButton = [self newButtonWithTitle:@"Auto Zoom" action:@selector(toggleSmartZoom)];
	
	NSArray<__kindof UIView*>* buttons = @[
		_blurButton,
		_replaceButton,
		_denoiseButton,
		_beautificationButton,
		_colorCorrectionButton,
		_smartZoomButton
	];
	
	CGFloat width = 0;
	CGFloat height = 0;
	for(UIView* button in buttons) {
		CGSize size = [button intrinsicContentSize];
		width += size.width;
		height = MAX(size.height, height);
	}
	
	UIStackView* buttonStack = [[UIStackView alloc] initWithArrangedSubviews:buttons];
	buttonStack.alignment = UIStackViewAlignmentCenter;
	buttonStack.layoutMarginsRelativeArrangement= YES;
	
	CGRect stackFrame = CGRectMake(0, 0, width, height);
	[buttonStack setFrame:stackFrame];
	
	UIScrollView* scroll = [[UIScrollView alloc] initWithFrame:CGRectZero];
	[scroll addSubview:buttonStack];
	scroll.contentInset = UIEdgeInsetsMake(0, 48, 0, 48);
	scroll.contentSize = buttonStack.frame.size;
	scroll.contentOffset = CGPointMake(-48, 0);
	[scroll setFrame:CGRectMake(0, -height, 0, height)];
	scroll.autoresizingMask =
		UIViewAutoresizingFlexibleTopMargin |
		UIViewAutoresizingFlexibleWidth;
	scroll.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2f];
	
	return scroll;
}

-(void)updateTimeAndFPSLabels
{
	NSString* fpsText = [NSString stringWithFormat:@"%1.1f fps", _metrics.cameraFPS];
	_fpsLabel.text = fpsText;
	NSString* timeText = [NSString stringWithFormat:@"%1.2fms per frame", _metrics.averageTimePerFrame * 1000];
	_timeLabel.text = timeText;
	
	[self updateLabelPos:_fpsLabel topPos:38];
	CGFloat fpsLabelBottomPos = _fpsLabel.frame.origin.y + _fpsLabel.frame.size.height;
	[self updateLabelPos:_timeLabel topPos:fpsLabelBottomPos + 4];
}

-(void)updateLabelPos:(UILabel*)label topPos:(CGFloat)topPos
{
	CGFloat inset = 4;
	CGFloat rightPos = label.superview.frame.size.width;
	CGSize size = label.intrinsicContentSize;
	size.width += (inset * 2);
	size.height += (inset * 2);
	CGRect frame = CGRectMake(rightPos - size.width, topPos, size.width, size.height);
	[label setFrame:frame];
}

-(void)toggleBlurBackground
{
	[self dispatchControlActionWithDisabledControl:_blurButton action:^{
		@synchronized (self->_pipeline) {
			if (self->_blurEnabled) {
				[self->_pipeline disableBlurBackground];
				self->_blurEnabled = NO;
			}
			else {
				enum TSVBPipelineError error =
					[self->_pipeline enableBlurBackgroundWithPower:0.3f];
				self->_blurEnabled = TSVBPipelineErrorOk == error;
			}
			
			if (self->_blurEnabled) {
				[self->_pipeline disableReplaceBackground];
				[self->_pipeline disableDenoiseBackground];
				self->_replaceEnabled = NO;
				self->_denoiseEnabled = NO;
			}
		}
			
		[self setFeatureButtonStateAsync:self->_blurButton featureEnabled:self->_blurEnabled];
		[self setFeatureButtonStateAsync:self->_replaceButton featureEnabled:self->_replaceEnabled];
		[self setFeatureButtonStateAsync:self->_denoiseButton featureEnabled:self->_denoiseEnabled];
	}];
}

-(void)toggleReplaceBackground
{
	[self dispatchControlActionWithDisabledControl:_replaceButton action:^{
		if (self->_replaceEnabled) {
			@synchronized (self->_pipeline) {
				[self->_pipeline disableReplaceBackground];
			}
			self->_replaceEnabled = false;
		}
		else {
			[self enableReplaceBackground];
		}
		
		[self setFeatureButtonStateAsync:self->_blurButton featureEnabled:self->_blurEnabled];
		[self setFeatureButtonStateAsync:self->_replaceButton featureEnabled:self->_replaceEnabled];
		[self setFeatureButtonStateAsync:self->_denoiseButton featureEnabled:self->_denoiseEnabled];
	}];
}

-(void)toggleDenoiseBackground
{
	[self dispatchControlActionWithDisabledControl:_denoiseButton action:^{
		@synchronized (self->_pipeline) {
			if (self->_denoiseEnabled) {
				[self->_pipeline disableDenoiseBackground];
				self->_denoiseEnabled = NO;
			}
			else {
				enum TSVBPipelineError error =
					[self->_pipeline enableDenoiseBackground];
				self->_denoiseEnabled = TSVBPipelineErrorOk == error;
				if (self->_denoiseEnabled) {
					self->_pipeline.denoisePower = 1;
				}
			}
			
			if (self->_denoiseEnabled) {
				[self->_pipeline disableBlurBackground];
				[self->_pipeline disableReplaceBackground];
				self->_blurEnabled = NO;
				self->_replaceEnabled = NO;
			}
		}
			
		[self setFeatureButtonStateAsync:self->_blurButton featureEnabled:self->_blurEnabled];
		[self setFeatureButtonStateAsync:self->_replaceButton featureEnabled:self->_replaceEnabled];
		[self setFeatureButtonStateAsync:self->_denoiseButton featureEnabled:self->_denoiseEnabled];
	}];
}

-(bool)enableReplaceBackground
{
	NSBundle* bundle = [NSBundle mainBundle];
	NSString* backgroundFilePath = [bundle pathForResource:@"background_image" ofType:@"jpg"];
	id<TSVBFrame> background = [self->_frameFactory imageWithContentOfFile:backgroundFilePath];
		
	@synchronized (self->_pipeline) {
		id<TSVBReplacementController> controller;
		enum TSVBPipelineError error =
			[self->_pipeline enableReplaceBackground:&controller];
		if (TSVBPipelineErrorOk == error) {
			controller.background = background;
			self->_replaceEnabled = YES;
			[self->_pipeline disableBlurBackground];
			[self->_pipeline disableDenoiseBackground];
			self->_blurEnabled = NO;
			self->_denoiseEnabled = NO;
		}
		else {
			self->_replaceEnabled = NO;
		}
		
		return self->_replaceEnabled;
	}
}

-(void)toggleBeautification
{
	[self dispatchControlActionWithDisabledControl:_beautificationButton action:^{
		@synchronized (self->_pipeline) {
			if (self->_beautificationEnabled) {
				[self->_pipeline disableBeautification];
				self->_beautificationEnabled = NO;
			}
			else {
				enum TSVBPipelineError error =
					[self->_pipeline enableBeautification];
				self->_beautificationEnabled = TSVBPipelineErrorOk == error;
			}
		}
		
		[self setFeatureButtonStateAsync:self->_beautificationButton featureEnabled:self->_beautificationEnabled];
	}];
}

-(void)toggleColorCorrecton
{
	[self dispatchControlActionWithDisabledControl:_colorCorrectionButton action:^{
		@synchronized (self->_pipeline) {
			if (self->_colorCorrectionEnabled) {
				[self->_pipeline disableColorCorrection];
				self->_colorCorrectionEnabled = NO;
			}
			else {
				enum TSVBPipelineError error =
					[self->_pipeline enableColorCorrection];
				self->_colorCorrectionEnabled = TSVBPipelineErrorOk == error;
			}
		}
		
		[self setFeatureButtonStateAsync:self->_colorCorrectionButton featureEnabled:self->_colorCorrectionEnabled];
	}];
}

-(void)toggleSmartZoom
{
	[self dispatchControlActionWithDisabledControl:_smartZoomButton action:^{
		@synchronized (self->_pipeline) {
			if (self->_smartZoomEnabled) {
				[self->_pipeline disableSmartZoom];
				self->_smartZoomEnabled = NO;
			}
			else {
				enum TSVBPipelineError error =
					[self->_pipeline enableSmartZoom];
				self->_smartZoomEnabled = TSVBPipelineErrorOk == error;
			}
		}
		
		[self setFeatureButtonStateAsync:self->_smartZoomButton featureEnabled:self->_smartZoomEnabled];
	}];
}

-(void)dispatchControlActionWithDisabledControl:(UIControl*)control action:(void(^)(void))action
{
	control.enabled = NO;
	dispatch_async(_controlQueue, ^{
		action();
		dispatch_queue_t mainQ = dispatch_get_main_queue();
		dispatch_async(mainQ, ^{
			control.enabled = YES;
		});
	});
}

-(void)setFeatureButtonStateAsync:(UIButton*)button featureEnabled:(bool)featureEnabled
{
	dispatch_queue_t mainQ = dispatch_get_main_queue();
	dispatch_async(mainQ, ^{
		UIColor* color = featureEnabled?
			[self enabledFeatureButtonColor] : [self standardButtonColor];
		[button setTitleColor:color forState:UIControlStateNormal];
	});
}

-(UIColor*)standardButtonColor
{
	return [UIColor whiteColor];
}

-(UIColor*)enabledFeatureButtonColor
{
	return [UIColor greenColor];
}

-(UIInterfaceOrientationMask) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
