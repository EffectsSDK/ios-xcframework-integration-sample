#ifndef TOMSKSOFT_INCLUDE_TSVB_AUTHORIZATION_H
#define TOMSKSOFT_INCLUDE_TSVB_AUTHORIZATION_H

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TSVBAuthStatus)
{
	TSVBAuthStatusError = 0,
	TSVBAuthStatusActive = 1,
	TSVBAuthStatusInactive = 2,
    TSVBAuthStatusExpired = 3
} NS_SWIFT_NAME(AuthStatus);

NS_SWIFT_NAME(AuthResult)
@protocol TSVBAuthResult<NSObject>

@property(nonatomic, readonly) TSVBAuthStatus status;

@end

#endif
