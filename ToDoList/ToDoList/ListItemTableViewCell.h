//
//  ListItemTableViewCell.h
//  ToDoList
//
//  Created by Rameez Hussain on 29/10/15.
//  Copyright © 2015 Rameez Hussain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListItemTableViewCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UITextView *listItemText;
@property (nonatomic, strong) IBOutlet UILabel *lastModified;
@end
