//
//  TestUtil.h
//  CIOAPIClient
//
//  Created by Alex Pretzlav on 7/13/15.
//  Copyright (c) 2015 Context.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestUtil : NSObject

#define AssertRequestPathTypeMethod(request, requestPath, type, requestMethod) \
    do { \
        CIORequest *_req = (request); \
        if (![_req isKindOfClass:[type class]]) { \
            XCTFail(@"%@ is wrong type", _req); \
        } \
        XCTAssertEqualObjects(_req.path, (requestPath)); \
        XCTAssertEqualObjects(_req.method, (requestMethod)); \
    } while (0)

NS_ASSUME_NONNULL_BEGIN
+ (NSDictionary *)parseRequestBody:(NSURLRequest *)request;
+ (nullable NSString *)OAuthSignature:(NSString *)oAuthHeader;

NS_ASSUME_NONNULL_END

@end
