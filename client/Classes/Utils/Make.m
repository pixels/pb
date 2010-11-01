//
//  Make.m
//  iNocco
//
//  Created by Yusuke Kikkawa on 10/07/31.
//  Copyright 2010 3di. All rights reserved.
//

#import "Make.h"


@implementation Make

+ (UIButton *)button:(CGRect)rect title:(NSString *)title imagePath:(NSString *)imagePath {

	UIButton *btn = [[UIButton alloc] init];
	[btn setFrame:rect];
	[btn setTitle:title forState:UIControlStateNormal];
	
	if (imagePath) {
		UIImage *image = [[UIImage alloc] initWithContentsOfFile:imagePath];
		if (image) {
			[btn setBackgroundImage:image forState:UIControlStateNormal];
			[image release];
		}		
	}
	
	return btn;
}

@end
