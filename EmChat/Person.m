//
//  Person.m
//  EmChat
//
//  Created by Ashish Awaghad on 14/3/15.
//  Copyright (c) 2015 Alan Wong. All rights reserved.
//

#import "Person.h"
#import "Interest.h"
#import "Attraction.h"

NSString const *PIC_BASE_URL = @"http://61ce5cfa.ngrok.com/PIC/";

@implementation Person

-(NSDictionary*) toDictionary {
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setObject:_display_name forKey:@"display_name"];
    [dict setObject:_interests forKey:@"interests"];
    [dict setObject:_attractions forKey:@"attractions"];
    [dict setObject:UIImageJPEGRepresentation(_image, 0.8) forKey:@"image_data"];
    return [dict mutableCopy];
}

-(id)initWithDictionary:(NSDictionary*)pDictionary
{
    if ((self = [super init])) {
        self._id = [pDictionary objectForKey:@"_id"];
        self.display_name = [pDictionary objectForKey:@"display_name"];
        self.original_img_url = [[PIC_BASE_URL stringByAppendingString:[self._id stringValue]] stringByAppendingString:@".JPG"];
        self.blur_img_url = [[PIC_BASE_URL stringByAppendingString:[self._id stringValue]] stringByAppendingString:@"_BLUR.JPG"];
        NSArray *interestsArr = pDictionary[@"interests"];
        _interests = [NSMutableArray array];
        for (NSDictionary *dictionary in interestsArr)
        {
            Interest *interest = [[Interest alloc] initWithDictionary:dictionary];
            [_interests addObject:interest];
        }
        
        NSArray *thingsToDoArr = pDictionary[@"attractions"];
        _attractions = [NSMutableArray array];
        for (NSDictionary *dictionary in thingsToDoArr)
        {
            Attraction *interest = [[Attraction alloc] initWithDictionary:dictionary];
            [_attractions addObject:interest];
        }
        
    }
    return self;
}

@end
