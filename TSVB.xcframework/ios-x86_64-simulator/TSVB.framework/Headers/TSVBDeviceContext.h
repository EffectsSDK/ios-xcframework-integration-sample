#ifndef TOMSKSOFT_INCLUDE_TSVB_DEVICE_CONTEXT_H
#define TOMSKSOFT_INCLUDE_TSVB_DEVICE_CONTEXT_H

#import <Foundation/Foundation.h>

enum TSVBDeviceContextType
{
TSVBDeviceContextTypeOpenGLES = 1
};

@protocol TSVBDeviceContext<NSObject>

@property(nonatomic, readonly)enum TSVBDeviceContextType deviceContextType;

@end

#endif
