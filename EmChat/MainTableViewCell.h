//
//  MainTableViewCell.h
//  EmChat
//
//  Created by Alan Wong on 15/3/15.
//  Copyright (c) 2015 Alan Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *interests;
@property (weak, nonatomic) IBOutlet UILabel *attractions;
@property (weak, nonatomic) IBOutlet UIImageView *customImageView;
@end
