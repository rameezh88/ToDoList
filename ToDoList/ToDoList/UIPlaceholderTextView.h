//
//  UIPlaceholderTextView.h
//  HjalpHemma
//
//  Created by Rameez Hussain on 24/11/14.
//  Copyright (c) 2014 isolve. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIPlaceHolderTextView : UITextView

@property (nonatomic, retain) IBInspectable NSString *placeholder;
@property (nonatomic, retain) IBInspectable UIColor *placeholderColor;

-(void)textChanged:(NSNotification*)notification;

@end
