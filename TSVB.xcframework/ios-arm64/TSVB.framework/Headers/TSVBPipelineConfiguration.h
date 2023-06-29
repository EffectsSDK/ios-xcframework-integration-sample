#ifndef TOMSKSOFT_INCLUDE_TSVB_PIPELINE_CONFIGURATION_H
#define TOMSKSOFT_INCLUDE_TSVB_PIPELINE_CONFIGURATION_H

#import <Foundation/Foundation.h>

enum TSVBBackend
{
	TSVBBackendCPU = 1,
	TSVBBackendGPU = 2
};

enum TSVBSegmentationPreset
{
	TSVBSegmentationPresetQuality = 0,
	TSVBSegmentationPresetBalanced = 1,
	TSVBSegmentationPresetSpeed = 2,
	TSVBSegmentationPresetLightning = 3,
};

@protocol TSVBPipelineConfiguration<NSObject>

@property(nonatomic) enum TSVBBackend backend;

@property(nonatomic) enum TSVBSegmentationPreset segmentationPreset;

@end

#endif
