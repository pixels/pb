//
//  UITouchView.h
//  iNocco
//
//  Created by kikkawa on 10/08/11.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITouchViewTouch.h"

@interface UITouchView : UIView {
	id targetObject;
	SEL actionBegin;
	SEL actionMoved;
	SEL actionEnded;
}

- (void)addTarget:(id)target action:(SEL)action forTouchEvents:(UITouchViewTouch)touchEvents;

@end
