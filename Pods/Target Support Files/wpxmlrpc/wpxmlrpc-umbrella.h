#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "WPXMLRPC.h"
#import "WPXMLRPCEncoder.h"
#import "WPXMLRPCDecoder.h"

FOUNDATION_EXPORT double wpxmlrpcVersionNumber;
FOUNDATION_EXPORT const unsigned char wpxmlrpcVersionString[];

