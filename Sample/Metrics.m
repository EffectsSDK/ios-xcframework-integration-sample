#import "Metrics.h"

static const NSTimeInterval expirationTimeSecs = 1;

@implementation Metrics
{
	NSMutableArray<NSDate*>* _cameraFrameTimes;
	NSMutableArray<NSDateInterval*>* _intervals;
}

-(instancetype)init
{
	self = [super init];
	if (nil == self) {
		return nil;
	}
	
	_cameraFrameTimes = [NSMutableArray new];
	_intervals = [NSMutableArray new];
	return self;
}

-(void)didCameraFrame:(nonnull NSDate*)frameDate
{
	while(_cameraFrameTimes.count > 0) {
		NSDate* date = _cameraFrameTimes.firstObject;
		if ([frameDate timeIntervalSinceDate:date] > expirationTimeSecs) {
			[_cameraFrameTimes removeObjectAtIndex:0];
		}
		else {
			break;
		}
	}
	
	[_cameraFrameTimes addObject:frameDate];
}

-(void)didProcessFrameForInterval:(nonnull NSDateInterval*)interval
{
	NSDate* lastDate = interval.startDate;
	while(_intervals.count > 0) {
		NSDate* date = _intervals.firstObject.startDate;
		if ([lastDate timeIntervalSinceDate:date] > expirationTimeSecs) {
			[_intervals removeObjectAtIndex:0];
		}
		else {
			break;
		}
	}
	
	[_intervals addObject:interval];
}

-(NSTimeInterval)averageTimePerFrame
{
	if (_intervals.count < 1) {
		return 0;
	}
	
	NSTimeInterval sum = 0;
	for (NSDateInterval* interval in _intervals) {
		sum += interval.duration;
	}
	
	return sum / _intervals.count;
}

-(double)cameraFPS
{
	if (_cameraFrameTimes.count < 2) {
		return 0;
	}
	
	NSDate* prevFrameTime = _cameraFrameTimes.firstObject;
	NSTimeInterval intervalSum = 0;
	int intervalCount = 0;
	
	for(NSDate* frameTime in _cameraFrameTimes) {
		if (frameTime == prevFrameTime) {
			continue;
		}
		
		intervalSum += [frameTime timeIntervalSinceDate:prevFrameTime];
		intervalCount++;
		prevFrameTime = frameTime;
	}
	
	if (0 == intervalCount) {
		return 0;
	}
	
	return 1.0 / (intervalSum / intervalCount);
}

@end
