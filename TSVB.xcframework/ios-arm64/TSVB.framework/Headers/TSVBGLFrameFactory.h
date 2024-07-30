#ifndef TOMSKSOFT_INCLUDE_TSVB_GL_FRAME_FACTORY_H
#define TOMSKSOFT_INCLUDE_TSVB_GL_FRAME_FACTORY_H

#import <TSVB/TSVBGLFrame.h>

@protocol TSVBGLFrameFactory<NSObject>

- (nullable id<TSVBGLFrame>)newFrameWithGLTexture:(unsigned int)name
										   format:(TSVBFrameFormat)format
											width:(unsigned int)width
										   height:(unsigned int)height
										isFlipped:(bool)flipped;

-(nullable id<TSVBGLFrame>) imageWithContentOfFile:(nullable NSString*)filePath;

@end


#endif
