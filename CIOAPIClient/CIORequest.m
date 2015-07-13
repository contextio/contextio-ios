//
//  CIORequest.m
//  CIOAPIClient
//
//  Created by Alex Pretzlav on 7/10/15.
//  Copyright (c) 2015 Context.io. All rights reserved.
//

#import "CIORequest.h"

@interface CIORequest ()

@property (nonnull, nonatomic) NSURLRequest *URLrequest;

@end

@implementation CIORequest

+ (instancetype)withURLRequest:(NSURLRequest *)URLrequest {
    CIORequest *request = [[self alloc] init];
    request.URLrequest = URLrequest;
    return request;
}

@end

@implementation CIODictionaryRequest

@end

@implementation CIOArrayRequest

@end