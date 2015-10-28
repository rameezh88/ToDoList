//
//  UIColor+Hex.h
//  HjalpHemma
//
//  Created by Rameez Hussain on 05/11/14.
//  Copyright (c) 2014 isolve. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Hex)

// To generate UIColor from a hex string.
+ (UIColor *)colorWithHexString:(NSString *)str;

@end
