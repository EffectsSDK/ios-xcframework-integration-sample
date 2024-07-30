#ifndef TOMSKSOFT_INCLUDE_TSVB_PIPELINE_CONFIGURATION_H
#define TOMSKSOFT_INCLUDE_TSVB_PIPELINE_CONFIGURATION_H

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TSVBBackend)
{
	TSVBBackendCPU = 1,
	TSVBBackendGPU = 2
} NS_SWIFT_NAME(Backend);

typedef NS_ENUM(NSInteger, TSVBSegmentationPreset)
{
	TSVBSegmentationPresetQuality = 0,
	TSVBSegmentationPresetBalanced = 1,
	TSVBSegmentationPresetSpeed = 2,
	TSVBSegmentationPresetLightning = 3,
} NS_SWIFT_NAME(SegmentationPreset);

NS_SWIFT_NAME(PipelineConfiguration)
@protocol TSVBPipelineConfiguration<NSObject>

@property(nonatomic) TSVBBackend backend;

@property(nonatomic) TSVBSegmentationPreset segmentationPreset;

@end

#endif
