#ifndef TOMSKSOFT_INCLUDE_TSVB_PIPELINE_CONFIGURATION_H
#define TOMSKSOFT_INCLUDE_TSVB_PIPELINE_CONFIGURATION_H

#import <Foundation/Foundation.h>

enum TSVBBackend
{
	TSVBBackendCPU = 1,
	TSVBBackendGPU = 2
};

@protocol TSVBPipelineConfiguration<NSObject>

@property(nonatomic) enum TSVBBackend backend;

@end

#endif
