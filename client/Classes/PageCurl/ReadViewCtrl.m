//
//  ReadViewCtrl.m
//  WePublish
//
//  Created by Yusuke Kikkawa on 10/06/27.
//  Copyright 2010 3di. All rights reserved.
//

#import "GoodPBAppDelegate.h"
#import "ReadViewCtrl.h"
#import "WindowModeType.h"
#import "ReadViewBaseCtrl.h"
#import "ReadViewACtrl.h"
#import "UIImageViewWithTouch.h"
#import "ATSoundController.h"
#import "DirectionType.h"
#import "Define.h"
#import "Util.h"

#define CHANGE_ORIENTATION_ANIM_ID @"change_orientation_anim"
#define CHANGE_PAGE_SECOND 5
#define HIDE_NAVIGATION_BAR_SECOND 5

@implementation ReadViewCtrl
@synthesize bgView = bgView_;
@synthesize leftBtn = leftBtn_;
@synthesize recoredBtn = recoredBtn_;
@synthesize playBtn = playBtn_;
@synthesize rightBtn = rightBtn_;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	
	windowMode_ = MODE_NONE;
	
	NSInteger maxPage = pageNum_ - fakePage_;
	readViewACtrl_ = [[ReadViewACtrl alloc] initWithNibName:@"ReadViewA" bundle:0];
	
	[self.view insertSubview:readViewACtrl_.view atIndex:0];
	[readViewACtrl_.view setAlpha:0];
	[readViewACtrl_ setup:directory_ selectPage:selectPage_ pageNum:maxPage direction:direction_ windowMode:windowMode_];
	
	soundCtrl_ = [[ATSoundController alloc] init];
	
	[self initAnimation:CHANGE_ORIENTATION_ANIM_ID duration:0.25f];
	
	[readViewACtrl_.view setAlpha:1];
	[UIView commitAnimations];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTouchImage:) name:IMAGE_TOUCH_EVENT object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTapPage:) name:@"tapPageEvent" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGoToNextPage:) name:@"goToNextPageEvent" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGoToPrevPage:) name:@"goToPrevPageEvent" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBookmarkSaveSelect:) name:BOOKMARK_SAVE_EVENT object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTrackFinishedPlaying:) name:TRACK_FINISHED_PLAYING_EVENT object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPageChange:) name:PAGE_CHANGE_EVENT object:nil];
	
	[bgView_ setHidden:!mother_];
	[self setNavigationBarHidden:YES animated:NO];
	
	if (!mother_ && autoFlip_) {
		[self performSelector:@selector(playCurrentPageSound) withObject:nil afterDelay:CHANGE_PAGE_SECOND];
	}
}

- (void)setup:(NSString *)directory
   selectPage:(NSUInteger)selectPage
	  pageNum:(NSInteger)pageNum
	 fakePage:(NSInteger)fakePage
	direction:(NSInteger)direction
   windowMode:(NSInteger)windowMode
voicePackDirectory:(NSString *)voicePackDirectory
	 autoFlip:(BOOL)autoFlip
		 mute:(BOOL)mute
	   mother:(BOOL)mother {
	if (directory_) {
		[directory_ release];
		directory_ = nil;
	}
	if (voicePackDirectory_) {
		[voicePackDirectory_ release];
		voicePackDirectory_ = nil;
	}
	
	directory_ = [directory retain];
	selectPage_ = selectPage;
	pageNum_ = pageNum;
	fakePage_ = fakePage;
	direction_ = direction;
	voicePackDirectory_ = [voicePackDirectory retain];
	autoFlip_ = autoFlip;
	mute_ = mute;
	mother_ = mother;
}

- (void)initAnimation:(NSString *)animationID duration:(NSTimeInterval)duration {
	CGContextRef context = UIGraphicsGetCurrentContext();
	[UIView beginAnimations:animationID context:context];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:duration];
	[UIView setAnimationDelegate: self];
	[UIView setAnimationDidStopSelector:@selector(onAnimationEnd:finished:context:)];	
}

- (void)close {
	[self stopSound];
	[self stopNavigationBarTimer];
	[ReadViewCtrl cancelPreviousPerformRequestsWithTarget:self];
}

- (void)stopSound {
	if (mother_) {
		[playBtn_ setBackgroundImage:[UIImage imageNamed:@"media-play-inv.png"] forState:UIControlStateNormal];
	}
	
	if (soundCtrl_.status == StatusModePlaying) {
		NSLog(@"stopSound");
		[soundCtrl_ close];
	}
}

- (void)stopNavigationBarTimer {
	if (navigationBarTimer_) {
		[navigationBarTimer_ invalidate];
		navigationBarTimer_ = nil;
	}
}

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated {
	GoodPBAppDelegate *appDelegate = (GoodPBAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.navController setNavigationBarHidden:hidden animated:animated];
}

- (void)playSE:(NSString *)soundID {
	GoodPBAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[appDelegate.audioServicesController play:soundID];
}

- (void)changeOrientation {
	NSInteger maxPage = pageNum_ - fakePage_;
	selectPage_ = readViewACtrl_.currentPage;
	
	[readViewACtrl_ releaseAllBooks];
	[readViewACtrl_.view setAlpha:0];
	[readViewACtrl_ setup:directory_ selectPage:selectPage_ pageNum:maxPage direction:direction_ windowMode:windowMode_];
	[self initAnimation:CHANGE_ORIENTATION_ANIM_ID duration:0.25f];
	[readViewACtrl_.view setAlpha:1];
	[UIView commitAnimations];
}

- (void)cleanupCurrentView:(NSInteger)requireMode {
	if (requireMode == MODE_A) {
		if (readViewACtrl_) {
			[readViewACtrl_.view removeFromSuperview];
			[readViewACtrl_ release];
			readViewACtrl_ = nil;
		}
	}
	else {
	}
}

- (void)pageNext {
	NSLog(@"pageNext");

	[self playSE:@"page_change"];
	
	if ([readViewACtrl_ isNext]) {
		[readViewACtrl_ next];
		[self initAnimation:nil duration:0.5f];
		[UIView commitAnimations];
	}
}

- (void)pagePrev {
	NSLog(@"pagePrev");
	
	[self playSE:@"page_change"];
	
	if ([readViewACtrl_ isPrev]) {
		[readViewACtrl_ prev];
		[self initAnimation:nil duration:0.5f];
		[UIView commitAnimations];
	}
}

- (void)makeSoundPath:(NSUInteger)curretPage {
	if (soundPath_) {
		[soundPath_ release];
	}
	soundPath_ = [[NSString alloc] initWithFormat:@"%@/%04d.aiff", voicePackDirectory_, curretPage];
}

- (void)recoredMode:(BOOL)yes {
	[recoredBtn_ setBackgroundImage:[UIImage imageNamed:(yes ? @"media-microphone-inv2.png" : @"media-microphone-inv.png")] forState:UIControlStateNormal];
	[playBtn_ setHidden:yes];
	[leftBtn_ setHidden:yes];
	[rightBtn_ setHidden:yes];
}

- (BOOL)playCurrentPageSound {
//	NSLog(@"playCurrentPageSound %d", readViewACtrl_.currentPage);
	[self makeSoundPath:readViewACtrl_.currentPage];
	return [soundCtrl_ play:soundPath_];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	NSInteger requireMode;
	if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		return NO;
	} else {
		requireMode = MODE_B;
	}
	
	if (requireMode != windowMode_) {
		windowMode_ = requireMode;
		[self changeOrientation];
	}
	
    return YES;
}

-(void)onAnimationEnd:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	if ([animationID isEqualToString:CHANGE_ORIENTATION_ANIM_ID]) {
		if (windowMode_ == MODE_A) {
			self.view.frame = CGRectMake(0, 0, WINDOW_AW, WINDOW_AH);
		}
		else {
			self.view.frame = CGRectMake(0, 0, WINDOW_BW, WINDOW_BH);
		}
	}
}

- (void)onTouchImage:(NSNotification *)notification {
	NSArray *dic = [notification object];
	NSNumber *px = [dic objectAtIndex:1];
	
	if ([px floatValue] < (self.view.frame.size.width / 2)) {
		if (direction_ == DIRECTION_LEFT) {
			[self pageNext];
		}
		else {
			[self pagePrev];
		}
	}
	else {
		if (direction_ == DIRECTION_LEFT) {
			[self pagePrev];
		}
		else {
			[self pageNext];
		}
	}
}

- (void)onTapPage:(NSNotification *)notification {
	[self setNavigationBarHidden:NO animated:YES];
	
	[self stopNavigationBarTimer];
	
	navigationBarTimer_ = [NSTimer scheduledTimerWithTimeInterval:1.00 * HIDE_NAVIGATION_BAR_SECOND
											 target:self
										   selector:@selector(onNavigationBarTimer:)
										   userInfo:nil
											repeats:NO];
}

- (void)onNavigationBarTimer:(NSTimer*)timer {
	[self stopNavigationBarTimer];
	[self setNavigationBarHidden:YES animated:YES];
}

- (void)onGoToNextPage:(NSNotification *)notification {
	[self pageNext];
}

- (void)onGoToPrevPage:(NSNotification *)notification {
	[self pagePrev];
}

- (void)onTrackFinishedPlaying:(NSNotification *)notification {
	NSLog(@"onTrackFinishedPlaying SOUND FINISHED");
	
	if (mother_) {
		[self stopSound];
	}
	else {
		if (autoFlip_) {
			[self onNextPageWithAnimation];
		}
	}
}

- (void)onPageChange:(NSNotification *)notification {
	NSNumber *number = (NSNumber *)[notification object];
	[self makeSoundPath:[number intValue]];
	BOOL existingSound = [Util isExist:soundPath_];
	
	if (mother_) {
		[playBtn_ setHidden:!existingSound];
	}
	else {
		if (existingSound && !mute_) {
			existingSound = [self playCurrentPageSound];
		}
		
		if (!existingSound && autoFlip_) {
			[ReadViewCtrl cancelPreviousPerformRequestsWithTarget:self];
			[self performSelector:@selector(onNextPageWithAnimation) withObject:nil afterDelay:CHANGE_PAGE_SECOND];
		}
	}
}

- (void)onBookmarkSaveSelect:(NSNotification *)notification {
	NSDictionary *userInfo = [notification userInfo];
	NSNumber *currentPage = [userInfo objectForKey:BOOKMARK_PAGE];
	selectPage_ = [currentPage intValue];
}

- (void)onPrevPageWithAnimation {
//	NSLog(@"onPrevPageWithAnimation");
	
	if ([readViewACtrl_ isPrev]) {
		[readViewACtrl_ prevWithAnimation];
	}
}

- (void)onNextPageWithAnimation {
//	NSLog(@"onNextPageWithAnimation");
	
	if ([readViewACtrl_ isNext]) {
		[readViewACtrl_ nextWithAnimation];
	}
}

#pragma mark -
#pragma mark IBAction events

- (IBAction)onLeftPageTouchUpInside:(id)sender {
	if (direction_ == DIRECTION_LEFT) {
		[self onNextPageWithAnimation];
	}
	else {
		[self onPrevPageWithAnimation];
	}
}

- (IBAction)onRightPageTouchUpInside:(id)sender {
	if (direction_ == DIRECTION_LEFT) {
		[self onPrevPageWithAnimation];
	}
	else {
		[self onNextPageWithAnimation];
	}
}

- (IBAction)onRecordTouchUpInside:(id)sender {
	if (soundCtrl_.status == StatusModeWait) {
		[self makeSoundPath:readViewACtrl_.currentPage];
		[soundCtrl_ record:soundPath_];
		[self recoredMode:YES];
	}
	else if (soundCtrl_.status == StatusModeRecording) {
		[soundCtrl_ stop];
		[self recoredMode:NO];
	}
}

- (IBAction)onPlayTouchUpInside:(id)sender {
	if (soundCtrl_.status == StatusModeWait) {
		if ([self playCurrentPageSound]) {
			[playBtn_ setBackgroundImage:[UIImage imageNamed:@"media-play-inv2.png"] forState:UIControlStateNormal];
		}
	}
	else if (soundCtrl_.status == StatusModePlaying) {
		[self stopSound];
	}
	
}

- (void)dealloc {
	if (windowMode_ == MODE_A) {
		[self cleanupCurrentView:MODE_A];
	} else {
		[self cleanupCurrentView:MODE_B];
	}
	
	if (soundPath_) {
		[soundPath_ release];
	}
	
	[bgView_ release];
	[leftBtn_ release];
	[recoredBtn_ release];
	[playBtn_ release];
	[rightBtn_ release];
	[soundCtrl_ release];
	[directory_ release];
	[voicePackDirectory_ release];
	[super dealloc];
}

@end
