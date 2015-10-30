//
//  UIViewController+SessionOperations.h
//  HjalpHemma
//
//  Created by Rameez Hussain on 29/10/14.
//  Copyright (c) 2014 isolve. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (CommonOperations)

- (void) registerForKeyboardNotifications;
- (void) unregisterKeyboardNofifications;
- (CGSize) getScreenSize;
- (void) showAlertWithText: (NSString *) text andCancelButtonTitle: (NSString *) cancelButtonTitle;
- (void) showLoader;
- (void) hideLoader;
- (NSString *) deviceType;
@end
