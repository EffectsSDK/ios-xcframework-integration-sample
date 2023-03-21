#ifndef TOMSKSOFT_IOS_INCLUDE_TSVB_FRAME_FACTORY_H
#define TOMSKSOFT_IOS_INCLUDE_TSVB_FRAME_FACTORY_H

#import <TSVB/TSVBFrame.h>

@protocol TSVBFrameFactory<NSObject>

- (nullable id<TSVBFrame>) newFrameWithFormat:(enum TSVBFrameFormat)format
										 data:(nonnull void*)data
								 bytesPerLine:(unsigned int)bytesPerLine
										width:(unsigned int)width
									   height:(unsigned int)height
									makeCopy:(bool)makeCopy;

-(nullable id<TSVBFrame>) imageWithContentOfFile:(nullable NSString*)filePath;

@end

#endif
