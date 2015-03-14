//
//  Interest.m
//  EmChat
//
//  Created by Ashish Awaghad on 14/3/15.
//  Copyright (c) 2015 Alan Wong. All rights reserved.
//

#import "Interest.h"

@implementation Interest

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
        return self;
    }
    return self;
}

@end
