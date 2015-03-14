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

NSString const *PIC_BASE_URL = @"http://emchat.ngrok.com/PIC/";

@implementation Person

-(NSDictionary*) toDictionary {
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setObject:_display_name forKey:@"display_name"];
    
    NSMutableArray *interestsArr = [NSMutableArray array];
    
    for (Interest *interest in _interests) {
        [interestsArr addObject:[interest toDictionary]];
    }
    
    NSMutableArray *attractionsArr = [NSMutableArray array];
    
    for (Attraction *attraction in _attractions) {
        [attractionsArr addObject:[attraction toDictionary]];
    }
    
    [dict setObject:interestsArr forKey:@"interests"];
    [dict setObject:attractionsArr forKey:@"attractions"];
    [dict setObject:UIImageJPEGRepresentation(_image, 0.8) forKey:@"image_data"];
    return [dict mutableCopy];
}

-(id)initWithDictionary:(NSDictionary*)pDictionary
{
    if ((self = [super init])) {
        self._id = [pDictionary objectForKey:@"uid"];
        self.display_name = [pDictionary objectForKey:@"display_name"];
        self.original_img_url = [[PIC_BASE_URL stringByAppendingString:self._id] stringByAppendingString:@".JPG"];
        self.blur_img_url = [[PIC_BASE_URL stringByAppendingString:self._id] stringByAppendingString:@"_BLUR.JPG"];
        NSArray *interestsArr = pDictionary[@"interests"];
        _interests = [NSMutableArray array];
        for (NSDictionary *dictionary in interestsArr)
        {
            Interest *interest = [[Interest alloc] initWithDictionary:dictionary];
            [_interests addObject:interest];
        }
        self.interests = _interests;
        
        NSArray *thingsToDoArr = pDictionary[@"attractions"];
        _attractions = [NSMutableArray array];
        for (NSDictionary *dictionary in thingsToDoArr)
        {
            Attraction *attraction = [[Attraction alloc] initWithDictionary:dictionary];
            [_attractions addObject:attraction];
        }
        self.attractions = _attractions;
    }
    return self;
}

@end
