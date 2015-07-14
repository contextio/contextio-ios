//
//  TestUtil.h
//  CIOAPIClient
//
//  Created by Alex Pretzlav on 7/13/15.
//  Copyright (c) 2015 Context.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestUtil : NSObject

NS_ASSUME_NONNULL_BEGIN
+ (NSDictionary *)parseRequestBody:(NSURLRequest *)request;
+ (nullable NSString *)OAuthSignature:(NSString *)oAuthHeader;

NS_ASSUME_NONNULL_END

@end
