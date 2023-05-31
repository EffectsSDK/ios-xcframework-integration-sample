#ifndef TOMSKSOFT_INCLUDE_TSVB_EAGL_DEVICE_CONTEXT_H
#define TOMSKSOFT_INCLUDE_TSVB_EAGL_DEVICE_CONTEXT_H

#import <TSVB/TSVBGLDeviceContext.h>

#import <OpenGLES/EAGL.h>

@interface TSVBEAGLDeviceContext : NSObject<TSVBGLDeviceContext>

-(nullable id)initWithEAGL:(nonnull EAGLContext*)context;

+(nullable id)deviceContextWithEAGL:(nullable EAGLContext*)context;

@property(nonatomic, readonly, nonnull)EAGLContext* eaglContext;

@end

#endif
