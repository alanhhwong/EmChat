//
//  Attraction.m
//  EmChat
//
//  Created by Ashish Awaghad on 14/3/15.
//  Copyright (c) 2015 Alan Wong. All rights reserved.
//

#import "Attraction.h"

@implementation Attraction

-(NSMutableDictionary*) toDictionary {
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setObject:_name forKey:@"name"];
    [dict setObject:_match forKey:@"match"];
    return dict;
}

-(id)initWithDictionary:(NSDictionary*)pDictionary {
    if ((self = [super init])) {
        self.name = [pDictionary objectForKey:@"name"];
        self.match = [pDictionary objectForKey:@"match"];
    }
    return self;
}

@end
