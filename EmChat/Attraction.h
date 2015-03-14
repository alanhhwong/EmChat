//
//  Attraction.h
//  EmChat
//
//  Created by Ashish Awaghad on 14/3/15.
//  Copyright (c) 2015 Alan Wong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Attraction : NSObject

@property NSString* name;
@property NSNumber* match;

-(NSMutableDictionary*) toDictionary;

-(id)initWithDictionary:(NSDictionary*)pDictionary;

@end
