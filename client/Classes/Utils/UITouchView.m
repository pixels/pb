//
//  UITouchView.m
//  iNocco
//
//  Created by kikkawa on 10/08/11.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UITouchView.h"


@implementation UITouchView


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)addTarget:(id)target action:(SEL)action forTouchEvents:(UITouchViewTouch)touchEvents {
	targetObject = target;
	
	switch (touchEvents) {
		case UITouchViewTouchBegin:
			actionBegin = action;
			break;
		case UITouchViewTouchMoved:
			actionMoved = action;
			break;
		case UITouchViewTouchEnded:
			actionEnded = action;
			break;
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if (targetObject && actionBegin)
		[targetObject performSelector:actionBegin withObject:touches];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if (targetObject && actionMoved)
		[targetObject performSelector:actionMoved withObject:touches];
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (targetObject && actionEnded)
		[targetObject performSelector:actionEnded withObject:touches];
}

@end
