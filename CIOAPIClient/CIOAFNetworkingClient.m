//
//  CIOAFNetworkingClient.m
//  CIOAPIClient
//
//  Created by Alex Pretzlav on 7/10/15.
//  Copyright (c) 2015 Context.io. All rights reserved.
//

#import "CIOAFNetworkingClient.h"

static NSString * const kCIOAPIBaseURLString = @"https://api.context.io/2.0/";

@interface CIOAFNetworkingClient ()

@property (nonatomic) AFHTTPClient *HTTPClient;

@end

@implementation CIOAFNetworkingClient

- (id)initWithConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret token:(NSString *)token tokenSecret:(NSString *)tokenSecret accountID:(NSString *)accountID {
    self = [super initWithConsumerKey:consumerKey consumerSecret:consumerSecret token:token tokenSecret:tokenSecret accountID:accountID];
    if (!self) {
        return nil;
    }

    self.HTTPClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kCIOAPIBaseURLString]];
    [self.HTTPClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self.HTTPClient setDefaultHeader:@"Accept" value:@"application/json"];

    return self;
}

- (void)executRequest:(NSURLRequest *)request success:(nullable void (^)(id responseObject))successBlock failure:(nullable  void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
    AFHTTPRequestOperation *operation = [self.HTTPClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (successBlock) {
            successBlock(responseObject);
        }
    } failure:failureBlock];
    [self.HTTPClient enqueueHTTPRequestOperation:operation];
}

- (void)executeDictionaryRequest:(CIODictionaryRequest *)request success:(void (^)(NSDictionary *responseDict))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    [self executRequest:request.urlRequest
                success:success
                failure:failure];
}

- (void)executeArrayRequest:(CIOArrayRequest *)request success:(void (^)(NSArray *responseArray))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    [self executRequest:request.urlRequest
                success:success
                failure:failure];
}

@end
