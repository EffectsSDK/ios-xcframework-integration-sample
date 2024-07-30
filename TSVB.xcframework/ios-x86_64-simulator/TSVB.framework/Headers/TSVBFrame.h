#ifndef TOMSKSOFT_INCLUDE_TSVB_FRAME_H
#define TOMSKSOFT_INCLUDE_TSVB_FRAME_H

#import <Foundation/Foundation.h>
#import <CoreVideo/CVPixelBuffer.h>

typedef NS_ENUM(NSInteger, TSVBFrameFormat)
{
	TSVBFrameFormatBgra32 = 1,
	TSVBFrameFormatRgba32 = 2,
	TSVBFrameFormatNv12 = 3
} NS_SWIFT_NAME(FrameFormat);

typedef NS_ENUM(NSInteger, TSVBFrameLock)
{
	TSVBFrameLockRead = 1,
	TSVBFrameLockWrite = 2,
	TSVBFrameLockReadWrite = (TSVBFrameLockRead | TSVBFrameLockWrite)
} NS_SWIFT_NAME(Lock);

NS_SWIFT_NAME(LockedFrameData)
@protocol TSVBLockedFrameData<NSObject>

-(unsigned int)bytesPerLineOfPlanar:(int)index;
-(nullable void*)dataPointerOfPlanar:(int)index NS_RETURNS_INNER_POINTER;

@end

NS_SWIFT_NAME(Frame)
@protocol TSVBFrame<NSObject>

@property(nonatomic, readonly) unsigned int width;
@property(nonatomic, readonly) unsigned int height;

@property(nonatomic, readonly) TSVBFrameFormat format;

-(nullable id<TSVBLockedFrameData>)lock:(TSVBFrameLock)lock;

-(nullable CVPixelBufferRef)toCVPixelBuffer NS_RETURNS_INNER_POINTER;

@end

#endif
