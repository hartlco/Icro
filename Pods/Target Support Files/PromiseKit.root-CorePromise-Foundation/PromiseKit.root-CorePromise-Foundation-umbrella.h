#ifdef __OBJC__
#import <Cocoa/Cocoa.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "AnyPromise.h"
#import "fwd.h"
#import "PromiseKit.h"
#import "NSNotificationCenter+AnyPromise.h"
#import "NSTask+AnyPromise.h"
#import "NSURLSession+AnyPromise.h"
#import "PMKFoundation.h"

FOUNDATION_EXPORT double PromiseKitVersionNumber;
FOUNDATION_EXPORT const unsigned char PromiseKitVersionString[];

