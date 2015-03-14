//
//  Person.h
//  EmChat
//
//  Created by Ashish Awaghad on 14/3/15.
//  Copyright (c) 2015 Alan Wong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Person : NSObject

@property NSString *display_name;
@property NSString *original_img_url;
@property NSString *blur_img_url;
@property NSMutableArray *interests;
@property NSMutableArray *attractions;
@property UIImage *image;


@end
