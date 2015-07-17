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

@end

@implementation CIODictionaryRequest

@end

@implementation CIOArrayRequest

@end

@implementation CIOStringRequest

@end