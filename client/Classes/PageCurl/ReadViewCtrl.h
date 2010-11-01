//
//  ReadViewCtrl.h
//  WePublish
//
//  Created by Yusuke Kikkawa on 10/06/27.
//  Copyright 2010 3di. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WindowModeType.h"
#import "DirectionType.h"

@class ReadViewACtrl;
@class ATSoundController;

@interface ReadViewCtrl : UIViewController {
	UIView *bgView_;
	UIButton *leftBtn_;
	UIButton *recoredBtn_;
	UIButton *playBtn_;
	UIButton *rightBtn_;
	NSInteger windowMode_;
	NSInteger direction_;
	NSString *directory_;
	NSString *voicePackDirectory_;
	NSInteger pageNum_;
	NSInteger fakePage_;
	NSUInteger selectPage_;
	ReadViewACtrl *readViewACtrl_;
	ATSoundController *soundCtrl_;
	NSString *soundPath_;
	BOOL autoFlip_;
	BOOL mute_;
	BOOL mother_;
	NSTimer *navigationBarTimer_;
}

@property (nonatomic, retain) IBOutlet UIView *bgView;
@property (nonatomic, retain) IBOutlet UIButton *leftBtn;
@property (nonatomic, retain) IBOutlet UIButton *recoredBtn;
@property (nonatomic, retain) IBOutlet UIButton *playBtn;
@property (nonatomic, retain) IBOutlet UIButton *rightBtn;

- (void)setup:(NSString *)directory
   selectPage:(NSUInteger)selectPage
	  pageNum:(NSInteger)pageNum
	 fakePage:(NSInteger)fakePage
	direction:(NSInteger)direction
   windowMode:(NSInteger)windowMode
voicePackDirectory:(NSString *)voicePackDirectory
	 autoFlip:(BOOL)autoFlip
		 mute:(BOOL)mute
	   mother:(BOOL)mother;
- (void)initAnimation:(NSString *)animationID duration:(NSTimeInterval)duration;
- (void)close;
- (void)stopSound;
- (void)stopNavigationBarTimer;
- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated;
- (void)changeOrientation;
- (void)cleanupCurrentView:(NSInteger)requireMode;
- (void)pageNext;
- (void)pagePrev;
- (void)makeSoundPath:(NSUInteger)curretPage;
- (void)recoredMode:(BOOL)yes;
- (BOOL)playCurrentPageSound;
- (void)onTouchImage:(NSNotification *)notification;
- (void)onNavigationBarTimer:(NSTimer*)timer;
- (void)onPrevPageWithAnimation;
- (void)onNextPageWithAnimation;
- (IBAction)onLeftPageTouchUpInside:(id)sender;
- (IBAction)onRightPageTouchUpInside:(id)sender;
- (IBAction)onRecordTouchUpInside:(id)sender;
- (IBAction)onPlayTouchUpInside:(id)sender;

@end
