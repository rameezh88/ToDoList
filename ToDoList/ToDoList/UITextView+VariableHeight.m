//
//  UITextView+VariableHeight.m
//  ToDoList
//
//  Created by Rameez Hussain on 29/10/15.
//  Copyright © 2015 Rameez Hussain. All rights reserved.
//

#import "UITextView+VariableHeight.h"

@implementation UITextView (VariableHeight)

- (double) updateHeight {
    CGFloat fixedWidth = self.frame.size.width;
    CGSize newSize = [self sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = self.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    self.frame = newFrame;
    return newFrame.size.height;
}

@end
