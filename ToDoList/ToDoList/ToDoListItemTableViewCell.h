//
//  ToDoListItemTableViewCell.h
//  ToDoList
//
//  Created by Rameez Hussain on 04/11/15.
//  Copyright © 2015 Rameez Hussain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ToDoListItemTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIButton *checkBox;
@property (nonatomic, strong) IBOutlet UILabel *itemText;

@end
