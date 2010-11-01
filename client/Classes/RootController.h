//
//  RootController.h
//  iPage
//
//  Created by Yusuke Kikkawa on 10/09/16.
//  Copyright 2010 3di. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFOpenFlowView.h"

@class ReadViewCtrl;
@class VoicePackSelectController;

@interface RootController : UIViewController <AFOpenFlowViewDelegate, AFOpenFlowViewDataSource, UINavigationControllerDelegate> {
	VoicePackSelectController *voicePackSelectController_;
	UINavigationController *navController_;
	UIPopoverController *popoverController_;
	UIButton *femaleButton_;
	UIButton *backButton_;
	UIButton *forwardButton_;
	UIImageView *flagImage_;
	UILabel *voicePackTitleLabel_;
	UILabel *titleLabel_;
	UILabel *authorLabel_;
	ReadViewCtrl *readViewController_;
	AFOpenFlowView *flowView_;
	NSUInteger flowIndex_;
	NSMutableArray *voicePackList_;
	NSInteger voicePackMuteIndex_;
	NSInteger voicePackIndex_;
	CGSize voicePackViewSize_;
}

@property (nonatomic, retain) IBOutlet UIButton *femaleButton;
@property (nonatomic, retain) IBOutlet UIButton *backButton;
@property (nonatomic, retain) IBOutlet UIButton *forwardButton;
@property (nonatomic, retain) IBOutlet UIImageView *flagImage;
@property (nonatomic, retain) IBOutlet UILabel *voicePackTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *authorLabel;

- (IBAction)onBackTouchUpInside:(id)sender;
- (IBAction)onForwardTouchUpInside:(id)sender;

@end
