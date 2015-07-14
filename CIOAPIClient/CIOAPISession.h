//
//  CIOAPISession.h
//  CIOAPIClient
//
//  Created by Alex Pretzlav on 7/14/15.
//  Copyright (c) 2015 Context.io. All rights reserved.
//

#import "CIOAPIClient.h"
#import "CIORequest.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString * const CIOAPISessionURLResponseErrorKey;

@interface CIOAPISession : CIOAPIClient

- (void)executeDictionaryRequest:(CIODictionaryRequest *)request success:(nullable void (^)(NSDictionary *responseDict))success failure:(nullable void (^)(NSError *error))failure;

- (void)executeArrayRequest:(CIOArrayRequest *)request success:(nullable void (^)(NSArray *responseArray))success failure:(nullable void (^)(NSError *error))failure;

- (NSError *)errorForResponse:(NSHTTPURLResponse *)response responseObject:(nullable id)responseObject;
- (nullable id)parseResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END