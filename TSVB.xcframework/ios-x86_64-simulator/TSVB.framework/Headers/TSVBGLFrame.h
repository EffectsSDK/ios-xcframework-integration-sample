#ifndef TOMSKSOFT_INCLUDE_TSVB_GL_FRAME_H
#define TOMSKSOFT_INCLUDE_TSVB_GL_FRAME_H

#import <TSVB/TSVBFrame.h>

@protocol TSVBGLFrame<TSVBFrame>

@property(nonatomic, readonly) unsigned int glTextureName;
@property(nonatomic, readonly) bool isFlipped;

@end


#endif
