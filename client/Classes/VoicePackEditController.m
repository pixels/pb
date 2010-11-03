    //
//  VoicePackEditController.m
//  GoodPB
//
//  Created by kikkawa on 10/10/08.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GoodPBAppDelegate.h"
#import "VoicePackEditController.h"

#define ICON_SIZE 146
#define ICON_MARGIN_W 0
#define BUTTON_DISSELECT_ALPHA 0.5

@interface VoicePackEditController (InternalMethods)
- (void)setupIcons;
- (void)selectIconButton:(NSUInteger)index;
- (IBAction)onIconButtonTouchUpInside:(id)sender;
@end

@implementation VoicePackEditController
@synthesize textField = textField_;
@synthesize scrollView = scrollView_;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	list_ = [[NSMutableArray alloc] init];
	
	[self setupIcons];
	[self selectIconButton:0];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	GoodPBAppDelegate *appDelegate = (GoodPBAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.models.voicePackCollection updateObjectAtIndexAndKey:textField_.text index:voiceIndex_ key:@"voicePackName"];
	[appDelegate.models.voicePackCollection updateObjectAtIndexAndKey:[NSNumber numberWithInt:iconIndex_] index:voiceIndex_ key:@"voicePackIndex"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

- (void)dealloc {
	[list_ release];
	[scrollView_ release];
	[textField_ release];
    [super dealloc];
}


- (void)setupIcons {
	
	NSInteger count = 10;
	NSInteger i;
	UIButton *btn;

	[scrollView_ setContentSize:CGSizeMake((ICON_SIZE + ICON_MARGIN_W) * count, scrollView_.frame.size.height)];
	
	GoodPBAppDelegate *appDelegate = (GoodPBAppDelegate *)[[UIApplication sharedApplication] delegate];
	for (i = 0; i < count; i++) {
		
		
		btn = [UIButton buttonWithType:UIButtonTypeCustom];
		[btn.imageView setContentMode:UIViewContentModeScaleAspectFit];
		[btn setShowsTouchWhenHighlighted:YES];
		[btn setFrame:CGRectMake((ICON_SIZE + ICON_MARGIN_W) * i, 0, ICON_SIZE, ICON_SIZE)];
		[btn setTitle:nil forState:UIControlStateNormal];
		[btn setBackgroundImage:[appDelegate getIconFromIndex:i] forState:UIControlStateNormal];
//		[btn setAlpha:(i == 0 ? 1 : BUTTON_DISSELECT_ALPHA)];
		[btn setTag:i];
		[btn addTarget:self action:@selector(onIconButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
		[scrollView_ addSubview:btn];
		[list_ addObject:btn];
	}
}

- (void)setVoiceIndex:(NSUInteger)index {
	voiceIndex_ = index;
	
	GoodPBAppDelegate *appDelegate = (GoodPBAppDelegate *)[[UIApplication sharedApplication] delegate];
	VoicePackInfo *voicePackInfo = [appDelegate.models.voicePackCollection getAtIndex:voiceIndex_];
	[textField_ setText:voicePackInfo.voicePackName];
	[self selectIconButton:voicePackInfo.voicePackIndex];
}

- (void)selectIconButton:(NSUInteger)index {
	iconIndex_ = index;
	
	UIButton *btn;
	for (btn in list_) {
		[btn setAlpha:BUTTON_DISSELECT_ALPHA];
	}
	btn = [list_ objectAtIndex:index];
	[btn setAlpha:1];
}

- (IBAction)onIconButtonTouchUpInside:(id)sender {
	UIButton *btn = (UIButton *)sender;
	[self selectIconButton:btn.tag];
}

@end
