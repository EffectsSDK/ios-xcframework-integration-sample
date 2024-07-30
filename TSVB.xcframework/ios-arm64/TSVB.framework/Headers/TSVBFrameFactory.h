#ifndef TOMSKSOFT_INCLUDE_TSVB_FRAME_FACTORY_H
#define TOMSKSOFT_INCLUDE_TSVB_FRAME_FACTORY_H

#import <TSVB/TSVBFrame.h>

NS_SWIFT_NAME(FrameFactory)
@protocol TSVBFrameFactory<NSObject>

- (nullable id<TSVBFrame>) newFrameWithFormat:(TSVBFrameFormat)format
										 data:(nonnull void*)data
								 bytesPerLine:(unsigned int)bytesPerLine
										width:(unsigned int)width
									   height:(unsigned int)height
									makeCopy:(bool)makeCopy NS_SWIFT_NAME(newFrame(format:data:bytesPerLine:width:height:makeCopy:));

-(nullable id<TSVBFrame>) imageWithContentOfFile:(nullable NSString*)filePath;

@end

#endif
