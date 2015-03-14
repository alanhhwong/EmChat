//
//  AttractionTableViewCell.h
//  EmChat
//
//  Created by Ashish Awaghad on 14/3/15.
//  Copyright (c) 2015 Alan Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AttractionTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *attractionImageView;
@property (weak, nonatomic) IBOutlet UILabel *attractionLabel;
@property (weak, nonatomic) IBOutlet UIButton *checkmarkButton;
@end
