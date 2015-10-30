//
//  ListItemTableViewCell.m
//  ToDoList
//
//  Created by Rameez Hussain on 29/10/15.
//  Copyright © 2015 Rameez Hussain. All rights reserved.
//

#import "ListItemTableViewCell.h"

@implementation ListItemTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) layoutSubviews {
    [super layoutSubviews];
    [self.listItemText setScrollEnabled:NO];
}

@end
