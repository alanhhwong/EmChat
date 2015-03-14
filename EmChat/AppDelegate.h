//
//  AppDelegate.h
//  EmChat
//
//  Created by Alan Wong on 14/3/15.
//  Copyright (c) 2015 Alan Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATLMApplicationController.h"
#import "Person.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic) ATLMApplicationController *applicationController;

-(void) showMainWindow:(Person*) person;

@end

