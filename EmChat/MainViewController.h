//
//  MainViewController.h
//  EmChat
//
//  Created by Alan Wong on 15/3/15.
//  Copyright (c) 2015 Alan Wong. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"

@interface MainViewController : ViewController

@property Person *me;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
