//
//  CIOAFNetworkingClient.h
//  CIOAPIClient
//
//  Created by Alex Pretzlav on 7/10/15.
//  Copyright (c) 2015 Context.io. All rights reserved.
//

#import "CIOAPIClient.h"

#import <SystemConfiguration/SystemConfiguration.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AFNetworking/AFNetworking.h>

NS_ASSUME_NONNULL_BEGIN

@interface CIOAFNetworkingClient : CIOAPIClient

/**
 The HTTP client used to interact with the API.
 */
@property (readonly, nonatomic) AFHTTPClient *HTTPClient;

- (void)executeDictionaryRequest:(CIODictionaryRequest *)request success:(nullable void (^)(NSDictionary *responseDict))success failure:(nullable void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

- (void)executeArrayRequest:(CIOArrayRequest *)request success:(nullable void (^)(NSArray *responseArray))success failure:(nullable void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
