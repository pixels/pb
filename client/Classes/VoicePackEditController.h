//
//  VoicePackEditController.h
//  PictureBooks
//
//  Created by kikkawa on 10/10/08.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface VoicePackEditController : UIViewController {
	UITextField *textField_;
	UIScrollView *scrollView_;
	NSMutableArray *list_;
	NSUInteger voiceIndex_;
	NSUInteger iconIndex_;
}

@property (nonatomic, retain) IBOutlet UITextField *textField;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

- (void)setVoiceIndex:(NSUInteger)index;

@end
