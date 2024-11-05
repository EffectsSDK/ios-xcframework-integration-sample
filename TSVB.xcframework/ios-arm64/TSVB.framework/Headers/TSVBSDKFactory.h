#ifndef TOMSKSOFT_INCLUDE_TSVB_SDK_FACTORY_H
#define TOMSKSOFT_INCLUDE_TSVB_SDK_FACTORY_H

#import <Foundation/Foundation.h>

#import <TSVB/TSVBAuthorization.h>

@protocol TSVBFrameFactory;
@protocol TSVBGLFrameFactory;
@protocol TSVBPipeline;
@protocol TSVBGLFrameFactory;
@protocol TSVBDeviceContext;
@protocol TSVBGLDeviceContext;

typedef void (^TSVBAuthCompletionHandler) (id<TSVBAuthResult>_Nullable result, NSError*_Nullable error);

NS_SWIFT_NAME(SDKFactory)
@interface TSVBSDKFactory : NSObject

-(void)authWithCustomerID:(nonnull NSString*)customerID completionHandler:(TSVBAuthCompletionHandler)completionHandler
	NS_SWIFT_NAME(auth(customerID:completionHandler:));

- (nullable id<TSVBFrameFactory>) newFrameFactory;
- (nullable id<TSVBGLFrameFactory>) newGLFrameFactoryWithContext:
				(nonnull id<TSVBGLDeviceContext>)context 
				NS_SWIFT_UNAVAILABLE("Deprecated: Use newFrameFactory instead.");
- (nullable id<TSVBPipeline>) newPipeline;
- (nullable id<TSVBPipeline>) newPipelineWithContext:
				(nonnull id<TSVBDeviceContext>)context 
				NS_SWIFT_UNAVAILABLE("Deprecated: Use newPipeline instead.");

@end

#endif
