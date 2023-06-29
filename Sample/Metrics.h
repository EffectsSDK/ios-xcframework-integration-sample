#ifndef metrics_h
#define metrics_h

#import <Foundation/Foundation.h>

@interface Metrics : NSObject

-(void)didCameraFrame:(nonnull NSDate*)frameDate;

-(void)didProcessFrameForInterval:(nonnull NSDateInterval*)interval;

@property(nonatomic, readonly) NSTimeInterval averageTimePerFrame;
@property(nonatomic, readonly) double cameraFPS;

@end

#endif
