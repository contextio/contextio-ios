//
//  CIORequest.m
//  CIOAPIClient
//
//  Created by Alex Pretzlav on 7/10/15.
//  Copyright (c) 2015 Context.io. All rights reserved.
//

#import "CIORequest.h"

@interface CIORequest ()

@property (nonatomic) CIOAPIClient *client;
@property (nonnull, nonatomic) NSURLRequest *urlRequest;

@end

@implementation CIORequest

+ (instancetype)withURLRequest:(NSURLRequest *)URLrequest client:(CIOAPIClient *)client {
    CIORequest *request = [[self alloc] init];
    request.urlRequest = URLrequest;
    request.client = client;
    return request;
}

- (NSError *)validateResponseObject:(id)response {
    if ([response isKindOfClass:[NSDictionary class]]) {
        NSNumber *success = ((NSDictionary *)response)[@"success"];
        if ([success isKindOfClass:[NSNumber class]]) {
            if (![success boolValue]) {
                return [NSError errorWithDomain:@"io.context.error.response.object"
                                    code:NSURLErrorBadServerResponse
                                userInfo:@{NSLocalizedDescriptionKey: @"Request unsuccessful"}];
            }
        }
    }
    return nil;
}

- (NSError *)_validateResponse:(id)response ofType:(Class)type {
    if (![response isKindOfClass:type]) {
        NSString *errorString = [NSString stringWithFormat:@"Wrong response type: %@ expecting: %@",
                                 [response class], NSStringFromClass(type)];
        return [NSError errorWithDomain:@"io.context.error.response.type"
                                   code:NSURLErrorBadServerResponse
                               userInfo:@{NSLocalizedDescriptionKey: errorString}];
    }
    return nil;
}

@end

@implementation CIODictionaryRequest

- (NSError *)validateResponseObject:(id)response {
    NSError *error = [super validateResponseObject:response];
    if (error) {
        return error;
    }
    return [self _validateResponse:response ofType:[NSDictionary class]];
}

@end

@implementation CIOArrayRequest

- (NSError *)validateResponseObject:(id)response {
    NSError *error = [super validateResponseObject:response];
    if (error) {
        return error;
    }
    return [self _validateResponse:response ofType:[NSArray class]];
}

@end

@implementation CIOStringRequest

- (NSError *)validateResponseObject:(id)response {
    NSError *error = [super validateResponseObject:response];
    if (error) {
        return error;
    }
    return [self _validateResponse:response ofType:[NSString class]];
}

@end