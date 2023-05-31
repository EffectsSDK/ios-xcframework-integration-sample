#ifndef TOMSKSOFT_INCLUDE_TSVB_PIPELINE_H
#define TOMSKSOFT_INCLUDE_TSVB_PIPELINE_H

#import <Foundation/Foundation.h>

#import <TSVB/TSVBFrame.h>
#import <TSVB/TSVBPipelineConfiguration.h>

enum TSVBPipelineError
{
	TSVBPipelineErrorOk = 0,
	TSVBPipelineErrorInvalidArguemnt = 1,
	TSVBPipelineErrorNoFeaturesEnabled = 2,
	TSVBPipelineErrorEngineInitializationError = 3,
	TSVBPipelineErrorResourceAllocationError = 4
};

@protocol TSVBReplacementController<NSObject>

@property(nonatomic, retain, nullable) id<TSVBFrame> background;

@end

@protocol TSVBPipeline<NSObject>

-(enum TSVBPipelineError)setConfiguration:(id<TSVBPipelineConfiguration>_Nonnull)configuration;
-(nullable id<TSVBPipelineConfiguration>)copyConfiguration;
-(nullable id<TSVBPipelineConfiguration>)copyDefaultConfiguration;

-(enum TSVBPipelineError)enableBlurBackgroundWithPower:(float)power;
-(void) disableBlurBackground;

-(enum TSVBPipelineError)enableReplaceBackground:
    (id<TSVBReplacementController>_Nullable*_Nullable)controller;
-(void) disableReplaceBackground;

-(enum TSVBPipelineError)enableBeautification;
-(void) disableBeautification;
@property(nonatomic) float beautificationLevel;

-(enum TSVBPipelineError)enableColorCorrection;
-(void) disableColorCorrection;

-(enum TSVBPipelineError)enableSmartZoom;
-(void) disableSmartZoom;
@property(nonatomic) float smartZoomLevel;

-(nullable id<TSVBFrame>) process:(nonnull id<TSVBFrame>)frame
							error:(nullable enum TSVBPipelineError*)error;

@end

#endif
