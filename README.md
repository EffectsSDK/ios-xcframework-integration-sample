# Video Effects SDK - iOS trial SDK frameworks and Samples

Add real-time AI video enhancement that makes video meeting experience more effective and comfortable to your application in a few hours.

This repository contains the trial version of Objective-C iOS xcframeworks versions of Effects SDK that you can integrate into your project/product to see how it will work in real conditions.

Also, there is the Sample Xcode project with Effects SDK integration, so you can just build and run it to see SDK in action.


## Obtaining Effects SDK License

To receive a Effects SDK license please fill in the contact form on [effectssdk.com](https://effectssdk.com/contacts) website.

## Techical Details

- SDK available for iOS 13 and newer.
- Frames preprocessing/postprocessing could be run on CPU or GPU.
- ML inference could be run only on CPU.

## Features

- Virtual backgrounds (put image as a background) - **implemented**
- Background blur - **implemented**
- Beautification/Touch up my appearance - **implemented**
- Auto framing/Smart Zoom - **implemented**
- Auto color correction - **implemented**
- Color grading - **in progress**

## Usage  details

The entrypoint of the SDK is the instance of TSVBSDKFactory. 
Using an TSVBSDKFactory instance you will be able to prepare frames for processing and configure the pipeline of processing (enable transparency, blur, replace background etc).

### Usage

Preparation:
- Create an instance of **TSVBSDKFactory**.
- Create an instance of **TSVBFrameFactory** by using **newFrameFactory** method of **TSVBSDKFactory**.
- Create an instance of **TSVBPipeline** by using **newPipeline** method of **TSVBSDKFactory**.
- Enable background blur using **enableBlurBackgroundWithPower:** mthod or background replacement using **enableReplaceBackground:** method of **TSVBPipeline**.
- When the background replacement is enabled you can pass image which will be used as a background: **TSVBReplacementController.background**

Frame processing:
- Put your frame to **TSVBFrame** using **newFrameWithFormat:data:bytesPerLine:width:height:makeCopy:** method of **TSVBFrameFactory**.
- Process it through **process:error:** method of **TSVBPipeline**.

Use separate **TSVBPipeline** instances per video stream.

```objc
-(nullable id)init
{
    self = [super init];
	
    TSVBSDKFactory* sdkFactory = [TSVBSDKFactory new];
    _frameFactory = [sdkFactory newFrameFactory];
    _pipeline = [sdkFactory newPipeline];
    [_pipeline enableReplaceBackground:&_backgroundController];
    
    return self;
}
```

## Class Reference

### TSVBSDKFactory

```objc
-(nullable id<TSVBFrameFactory>)newFrameFactory; 
```
Creates new instance of **TSVBFrameFactory**.

```objc
-(nullable TSVBPipeline)newPipeline;
```
Creates new instance of **TSVBPipeline**.

### enum TSVBFrameFormat 

- **TSVBFrameFormatRGBA** - RGBA format with 8 bits per channel (32 bits per pixel).
- **TSVBFrameFormatBGRA** - BGRA format with 8 bits per channel (32 bits per pixel).

### enum TSVBFrameLock 

- **TSVBFrameLockRead**  
- **TSVBFrameLockWrite**
- **TSVBFrameLockReadWrite** 

### TSVBFrameFactory

```objc
-(id<TSVBFrame>)newFrameWithFormat:(TSVBFrameFormat)format
					data:(void*)data
				bytesPerLine:(unsigned int)bytesPerLine
					width:(unsigned int)width
					height:(unsigned int)height
					makeCopy:(bool)makeCopy;
```
Creates **TSVBFrame** from raw RGBA or BGRA data. 

Parameters:
- **(TSVBFrameFormat)format** - format of raw data.
- **(void\*)data** - pointer at raw data.
- **(unsigned int)bytesPerLine** - number of bytes per line of frame.
- **(unsigned int)width** - number of pixels in horizontal direction.
- **(unsigned int)height** - number of pixels in vertical direction.
- **(bool)makeCopy** - if set to true - data will be copied, otherwise TSVBFrame will keep the pointer to data (DON'T release the data while it's processing).

```objc
-(id<TSVBFrame>)imageWithContentOfFile:(NSString*)filePath;
```

Loads the image file and returns it as a **TSVBFrame**. If ARC disabled then use it within @autoreleasepool\{ \}

### TSVBFrame

```objc
@property(nonatomic, readonly) unsigned int width;
```
Returns number of pixels in horizontal direction.

```objc
@property(nonatomic, readonly) unsigned int height;
```
Returns number of pixels in vertical direction.

```objc
@property(nonatomic, readonly) TSVBFrameFormat format;
```
Returns format of frame.

```objc
-(id<TSVBLockedFrameData>)lock:(TSVBFrameLock)lock;
```
Gets access to memory of the frame. 
Returns TSVBLockedFrameData protocol which provides ability to get pointers to internal data of TSVBFrame (DON’T use the TSVBFrame until TSVBLockedFrameData wasn’t released). 
If ARC is disabled then use it within @autoreleasepool\{ \}.

```objc
-(nullable CVPixelBufferRef)toCVPixelBuffer;
```
 Converts internal storage to CVPixelBuffer and returns that reference if successful, otherwise returns NULL. If internal storage is CVPixelBuffer already then returns that reference. To keep CVPixelBuffer after TSVBFrame released, call CVPixelBufferRetain. TSVBFrame must not be used after toCVPixelBuffer called.


### TSVBLockedFrameData 

Keeps access to the data inside TSVBFrame and returns pointers to that data.
If it was obtained with **lock:TSVBFrameLockWrite** or  **lock:TSVBFrameLockReadWrite** , then the changes will be applied after TSVBLockedFrameData will be released. 
If it was obtained with **lock:TSVBFrameLockRead** then data nust not be changed.

```objc
-(void*)dataPointerOfPlanar:(int)index;
```
Returns pointer to planar data. If the **TSVBFrame** created by **newFrameWithFormat:data:bytesPerLine:width:height:makeCopy:** where makeCopy was false then returns same pointer that was passed 
Parameters:
- **int index** - depends on frame format. For TSVBFrameFormatRGBA or TSVBFrameFormatBGRA always should be used 0. For TSVBFrameFormatNV12  - 0 returns pointer to Y component, 1 returns pointer to UV component. 

```objc
-(unsigned int)bytesPerLineOfPlanar:(int)index;
```
Returns number of bytes per line.
Parameters:
- **int index** - see **dataPointerOfPlanar:**.

### TSVBPipelineErrorCode - error codes

- **TSVBPipelineErrorOk** - success
- **TSVBPipelineErrorInvalidArgument** - one or more arguments are incorrect.
- **TSVBPipelineErrorNoFeaturesEnabled** - processing pipeline is not configured.
- **TSVBPipelineErrorEngineInitializationError** - can’t initialize OpenVINO, the hardware/software is not supported.
- **TSVBPipelineErrorResourceAllocationError** -  not enough memory, disc space etc.

### TSVBPipeline 

Configuration of effects and frame processor. Use separate instances for each video stream.

```objc
-(TSVBPipelineError)setConfiguration:(id<TSVBPipelineConfiguration> _Nonnull)configuration;
```
Configures pipeline, determines what to use for image processing (see **TSVBPipelineConfiguration**). This method is optional.

```objc
-(id<TSVBPipelineConfiguration>)copyConfiguration;
```
Returns a copy of current configuration of pipeline. Can be used to get an instance of TSVBPipelineConfiguration.

```obcj
-(id<TSVBPipelineConfiguration>)copyDefaultConfiguration;
```
Returns a copy of the default configuration. Can be used to get an instance of TSVBPipelineConfiguration.

```objc
-(TSVBPipelineError)enabledBackgroundBlurWithPower:(float)power;
```
Enables background blur.
Parameters:
- **float power** - power of blur from 0 to 1.

```objc
-(void)disableBackgroundBlur
```
Disables background blur.

```objc
-(TSVBPipelineError)enabledReplaceBackground:(id<ReplacementController>*)controller;
```
Enables background replacement, default background is transparent\. The custom image for the background could be set using the property background of TSVBReplacementController\.
Parameters:
- **(id\<TSVBReplacementController\>\*)controller** - Pointer at variable to store an instance of **TSVBReplacementController**. Can be null. Caller is responsible to manage the memory for the objects manually if ARC disabled.

**TSVBReplacementController**. If background blur is enabled, then the custom image will be also blurred.

```objc
-(void)disableReplaceBackground;
```
Disables background replacement.

```objc
-(enum TSVBPipelineError)enableDenoiseBackground;
```
Enables video denoising. By default, denoises the background only; to denoise the foreground, set denoiseWithFace to YES.

```objc
-(void) disableDenoiseBackground;
```
Disables denoising.

```objc
@property(nonatomic) float denoisePower;
```
Power of denoising: higher number = more visible effect.
Value from 0 to 1.

```objc
@property(nonatomic) bool denoiseWithFace;
```
If YES, the pipeline denoises the background and foreground of the video. Otherwise, background only.
Default is NO.

```objc
-(TSVBPipelineError)enabledBeautification;
```
Enables face beautification. 

```objc
-(void)disableBeautification;
```
Disables face beautification.

```objc
@property(nonatomic) float beautificationLevel;
```
Could be from 0 to 1. Higher number \-\> more visible effect of beautification.

```objc
-(TSVBPipelineError)enabledColorCorrection;
```
Enables color correction.
Note: Preparation starts asynchronously after a frame process, the effect may be delayed.

```objc
-(void)disableColorCorrection;
```
 Disables color correction.
 
```objc
-(TSVBPipelineError)enabledSmartZoom;
```
Enables smart zoom.

Smart Zoom crops around the face.

```objc
-(void)disableSmartZoom;
```
 Disables smart zoom.

```objc
@property(nonatomic) float smartZoomLevel;
```
Parameters
- **float smartZoomLevel** - could be from 0 to 1. Defines how much area should be filled by a face. Higher number \-\> more area. 

```objc
-(id<TSVBFrame>)process:(id<TSVBFrame>)frame error:(TSVBPipelineError*)error;
```
Returns processed frame the same format with input (with all effects applied). In case of error, returns NULL.
Parameters:
- **(id\<TSVBFrame\>)frame** - frame for processing.
- **(TSVBPipelineError\*)error** - NULL or error code.

```objc
-(id<TSVBFrame>)processCVPixelBuffer:(nonnull CVPixelBufferRef)pixelBuffer
							error:(nullable enum TSVBPipelineError*)error;
```
 Same as **process:error:** but expects CVPixelBufferRef as an argument. Supported formats are kCVPixelFormatType_32BGRA and kCVPixelFormatType_32RGBA.

### TSVBReplacementController 

```objc
@property(nonatomic, readwrite, nullable)id<TSVBFrame> background
```
Holds custom image for background replacement. If nil then processing replaces background by transparency. To reset the background set nil.


### TSVBPipelineConfiguration

```objc
@property(nonatomic)enum TSVBBackend backend
```
Determines pipeline that performs image processing.

### enum TSVBBackend 

- **TSVBBackendCPU** - CPU-based pipeline.
- **TSVBBackendGPU** - GPU-based pipeline.

```objc
@property(nonatomic)enum TSVBSegmentationPreset segmentationPreset
```
Set the segmentation mode. Segmentation mode allow to choose combination of quality and speed of segmentation. Quality mode is enabled by default.

### enum TSVBSegmentationPreset

- **TSVBSegmentationPresetQuality** - Quality is preferred.
- **TSVBSegmentationPresetBalanced** - Balanced quality and speed.
- **TSVBSegmentationPresetSpeed** - Speed is preferred.
- **TSVBSegmentationPresetLightning** - Speed is prioritized.
