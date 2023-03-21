#ifndef TOMSKSOFT_IOS_INCLUDE_TSVB_FRAME_H
#define TOMSKSOFT_IOS_INCLUDE_TSVB_FRAME_H

#import <Foundation/Foundation.h>

enum TSVBFrameFormat
{
	TSVBFrameFormatBgra32 = 1,
	TSVBFrameFormatRgba32 = 2,
	TSVBFrameFormatNv12 = 3
};

enum TSVBFrameLock
{
	TSVBFrameLockRead = 1,
	TSVBFrameLockWrite = 2,
	TSVBFrameLockReadWrite = (TSVBFrameLockRead | TSVBFrameLockWrite)
};

@protocol TSVBLockedFrameData<NSObject>

-(unsigned int)bytesPerLineOfPlanar:(int)index;
-(void*)dataPointerOfPlanar:(int)index NS_RETURNS_INNER_POINTER;

@end

@protocol TSVBFrame<NSObject>

@property(nonatomic, readonly) unsigned int width;
@property(nonatomic, readonly) unsigned int height;

@property(nonatomic, readonly) enum TSVBFrameFormat format;

-(id<TSVBLockedFrameData>)lock:(enum TSVBFrameLock)lock;

@end

#endif
