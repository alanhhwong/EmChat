//
//  MainTableViewCell.m
//  EmChat
//
//  Created by Alan Wong on 15/3/15.
//  Copyright (c) 2015 Alan Wong. All rights reserved.
//

#import "MainTableViewCell.h"

@implementation MainTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    _customImageView.layer.cornerRadius = CGRectGetHeight(_customImageView.frame)/2;
    _customImageView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
