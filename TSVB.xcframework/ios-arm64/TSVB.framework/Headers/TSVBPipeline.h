#ifndef TOMSKSOFT_INCLUDE_TSVB_PIPELINE_H
#define TOMSKSOFT_INCLUDE_TSVB_PIPELINE_H

#import <Foundation/Foundation.h>
#import <CoreVideo/CVPixelBuffer.h>

#import <TSVB/TSVBFrame.h>
#import <TSVB/TSVBPipelineConfiguration.h>

typedef NS_ENUM(NSInteger, TSVBPipelineError)
{
	TSVBPipelineErrorOk = 0,
	TSVBPipelineErrorInvalidArgument = 1,
	TSVBPipelineErrorNoFeaturesEnabled = 2,
	TSVBPipelineErrorEngineInitializationError = 3,
	TSVBPipelineErrorResourceAllocationError = 4
} NS_SWIFT_NAME(PipelineError);

NS_SWIFT_NAME(ReplacementController)
@protocol TSVBReplacementController<NSObject>

@property(nonatomic, retain, nullable) id<TSVBFrame> background;

@end

NS_SWIFT_NAME(Pipeline)
@protocol TSVBPipeline<NSObject>

-(TSVBPipelineError)setConfiguration:(id<TSVBPipelineConfiguration>_Nonnull)configuration;
-(nullable id<TSVBPipelineConfiguration>)copyConfiguration;
-(nullable id<TSVBPipelineConfiguration>)copyDefaultConfiguration;

-(TSVBPipelineError)enableBlurBackgroundWithPower:(float)power NS_SWIFT_NAME(enableBlurBackground(power:));
-(void) disableBlurBackground;

-(TSVBPipelineError)enableReplaceBackground:
    (id<TSVBReplacementController> __strong _Nullable* _Nullable)controller;
-(void) disableReplaceBackground;

-(TSVBPipelineError)enableDenoiseBackground;
-(void) disableDenoiseBackground;
@property(nonatomic) float denoisePower;
@property(nonatomic) bool denoiseWithFace;

-(TSVBPipelineError)enableBeautification;
-(void) disableBeautification;
@property(nonatomic) float beautificationLevel;

-(TSVBPipelineError)enableColorCorrection;
-(TSVBPipelineError)enableColorCorrectionWithReferance:(nonnull id<TSVBFrame>)reference;
-(TSVBPipelineError)enableColorCorrectionWithLutFile:(nonnull NSString*)filePath;
-(void) disableColorCorrection;
@property(nonatomic) float colorCorrectionPower;

-(TSVBPipelineError)enableSmartZoom;
-(void) disableSmartZoom;
@property(nonatomic) float smartZoomLevel;

-(TSVBPipelineError)enableLowLightAdjustment;
-(void)disableLowLightAdjustment;
@property(nonatomic) float lowLightAdjustmentPower;

-(TSVBPipelineError)enableSharpening;
-(void)disableSharpening;
@property(nonatomic) float sharpeningPower;

-(nullable id<TSVBFrame>) process:(nonnull id<TSVBFrame>)frame
							error:(nullable TSVBPipelineError*)error;

-(nullable id<TSVBFrame>)processCVPixelBuffer:(nonnull CVPixelBufferRef)pixelBuffer
							error:(nullable TSVBPipelineError*)error NS_SWIFT_NAME(process(pixelBuffer:error:));

@end

#endif
