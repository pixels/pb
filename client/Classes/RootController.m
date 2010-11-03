    //
//  RootController.m
//  iPage
//
//  Created by Yusuke Kikkawa on 10/09/16.
//  Copyright 2010 3di. All rights reserved.
//

#import "GoodPBAppDelegate.h"
#import "RootController.h"
#import "ReadViewCtrl.h"
#import "Util.h"
#import "FileUnzip.h"
#import "VoicePackSelectController.h"
#import "VoicePackEditController.h"

#define BUNDLE_FILE_NAME @"00000001"
#define BOOK_FILE_EXTENSION @"png"
#define MAX_COVER_WIDTH 480
#define MAX_COVER_HEIGHT 320
#define VOICE_PACK_BUTTON_COUNT 10
#define VOICE_PACK_BUTTON_SIZE 48
#define VOICE_PACK_BUTTON_MARGIN 48
#define VOICE_PACK_BUTTON_DISSELECT_ALPHA 0.5
#define VOICE_PACK_MUTE_MESSAGE @"音声無し＆自動ページめくり無し（普通の本としてご利用できます）"

@interface RootController (InternalMethods)
- (UIImage *)getFlagFromIOCName:(NSString *)iocName;
- (void)copySample;
- (void)reloadVoicePackButton;
- (void)selectVoicePackButton:(NSInteger)index;
- (void)changeIndex:(NSUInteger)index;
- (void)toRead:(int)index voicePackIndex:(NSInteger)voicePackIndex mother:(BOOL)mother;
- (Models *)getModels;
- (void)loadSE:(NSString *)soundID soundPath:(NSString *)soundPath;
- (void)playSE:(NSString *)soundID;
- (void)onEditVoicePackList:(NSNotification *)notification;
- (void)onSelectVoiceOfList:(NSNotification *)notification;
- (UIImage *)createCoverUIImage:(NSString *)path;
- (UIImage *)getIconFromIndex:(NSUInteger)index;
- (IBAction)onVoicePackTouchUpInside:(id)sender;
- (IBAction)onFemaleTouchUpInside:(id)sender;
- (IBAction)onBackTouchUpInside:(id)sender;
- (IBAction)onForwardTouchUpInside:(id)sender;
@end

@implementation RootController
@synthesize femaleButton = femaleButton_;
@synthesize backButton = backButton_;
@synthesize forwardButton = forwardButton_;
@synthesize flagImage = flagImage_;
@synthesize voicePackTitleLabel = voicePackTitleLabel_;
@synthesize titleLabel = titleLabel_;
@synthesize authorLabel = authorLabel_;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self copySample];
	
	// Sounds
	[self loadSE:@"move" soundPath:[Util getBandleFile:@"se_menu_move" type:@"wav"]];
	[self loadSE:@"select" soundPath:[Util getBandleFile:@"se_menu_select" type:@"wav"]];
	[self loadSE:@"page_change" soundPath:[Util getBandleFile:@"se_page_change" type:@"wav"]];
	
	flowView_ = [[AFOpenFlowView alloc] initWithFrame:CGRectMake(0, 0, 1024, 748)];
	flowView_.dataSource = self;
	flowView_.viewDelegate = self;
	flowView_.backgroundColor = [UIColor blackColor];
	[flowView_ setNumberOfImages:[[self getModels].bookCollection count]];
	[flowView_ setHitAreaOfImage:CGSizeMake(MAX_COVER_WIDTH / 2, MAX_COVER_HEIGHT / 2)];
	[self.view insertSubview:flowView_ atIndex:0];
	
	// VoicePack
	if ([self getModels].device.iPad) {
		voicePackList_ = [[NSMutableArray alloc] init];
		[self reloadVoicePackButton];
		
		CGSize popSize = CGSizeMake(480, 320);
		voicePackViewSize_ = CGSizeMake(480, 276);
		
		voicePackSelectController_ = [[VoicePackSelectController alloc] initWithNibNameAndValue:@"VoicePackSelectView" bundle:nil];
		UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithTitle:@"編集"
																	style:UIBarStyleDefault
																   target:voicePackSelectController_
																   action:@selector(onEditTouchUpInside)];
		[voicePackSelectController_ setTitle:@"ボイスの選択"];
		[voicePackSelectController_.navigationItem setRightBarButtonItem:barItem animated:NO];
		[barItem release];
		
		navController_ = [[UINavigationController alloc] initWithRootViewController:voicePackSelectController_];
		navController_.navigationBar.barStyle = UIBarStyleBlackTranslucent;
		navController_.delegate = self;
		
		popoverController_ = [[UIPopoverController alloc] initWithContentViewController:navController_];
		[popoverController_ setPopoverContentSize:popSize animated:NO];
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onEditVoicePackList:) name:@"EDIT_VOICE_PACK_LIST_EVENT" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSelectVoiceOfList:) name:@"SELECT_VOICE_OF_LIST_EVENT" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPushEditVoicePack:) name:@"PUSH_EDIT_VOICE_PACK_EVENT" object:nil];
	
	[self changeIndex:0];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIDeviceOrientationLandscapeLeft || interfaceOrientation == UIDeviceOrientationLandscapeRight);
}

- (void)dealloc {
	[voicePackList_ release];
	[flowView_ release];
	[femaleButton_ release];
	[backButton_ release];
	[forwardButton_ release];
	[flagImage_ release];
	[voicePackTitleLabel_ release];
	[titleLabel_ release];
	[authorLabel_ release];
	[navController_ release];
	[popoverController_ release];
	[voicePackSelectController_ release];
    [super dealloc];
}

- (void)copySample {
	NSArray *idList = [[NSArray alloc] initWithObjects:
					   @"BOOK_JPN_00000000",
					   @"BOOK_JPN_00000001",
					   @"BOOK_USA_00000001",
					   @"BOOK_JPN_00000002",
					   nil];
	
	
	FileUnzip *unzip = [[FileUnzip alloc] init];
	NSString *outputDir = [[NSString alloc] initWithFormat:@"%@", [Util getLocalDocument]];
	for (NSString *bookID in idList) {
		NSString *bookDir = [NSString stringWithFormat:@"%@/%@", outputDir, bookID];
		if ([Util isExist:bookDir]) {
			NSLog(@"copySample exist!");
			continue;
		}
		
		NSString *fromZipPath = [Util getBandleFile:bookID type:@"zip"];
		NSString *toZipPath = [NSString stringWithFormat:@"%@.zip", bookDir];
		[[NSFileManager defaultManager] copyItemAtPath:fromZipPath toPath:toZipPath error:nil];
		[unzip unzip:toZipPath outputDir:outputDir removeZipFile:YES];
	}
	[outputDir release];
	[unzip release];
}

- (void)reloadVoicePackButton {
	
	UIScreen *sc = [UIScreen mainScreen];
	VoicePackCollection *vpc = [self getModels].voicePackCollection;
	NSUInteger voicePackCount = [vpc count];
	VoicePackInfo *voicePackInfp;
	NSUInteger w;
	UIButton *btn;
	float x;
	float y;
	float offX = (sc.applicationFrame.size.height - ((VOICE_PACK_BUTTON_SIZE + VOICE_PACK_BUTTON_MARGIN) * VOICE_PACK_BUTTON_COUNT) + VOICE_PACK_BUTTON_MARGIN) / 2;

	// Remove old data.
	for (btn in voicePackList_) {
		[btn removeFromSuperview];
	}
	[voicePackList_ removeAllObjects];

	// Add.
	voicePackMuteIndex_ = voicePackCount;
	NSInteger max_and_muto_count = voicePackCount + 1;
	for (w = 0; w < max_and_muto_count; w++) {
		x = (VOICE_PACK_BUTTON_SIZE + VOICE_PACK_BUTTON_MARGIN) * w + offX;
		y = 64;
		btn = [UIButton buttonWithType:UIButtonTypeCustom];
		[btn.imageView setContentMode:UIViewContentModeScaleAspectFit];
		[btn setShowsTouchWhenHighlighted:YES];
		[btn setFrame:CGRectMake(x, y, VOICE_PACK_BUTTON_SIZE, VOICE_PACK_BUTTON_SIZE)];
		[btn setTitle:nil forState:UIControlStateNormal];
		if (w == voicePackCount) {
			[btn setBackgroundImage:[UIImage imageNamed:@"media-volume-0-inv2.png"] forState:UIControlStateNormal];
		}
		else {
			voicePackInfp = [vpc getAtIndex:w];
			[btn setBackgroundImage:[(GoodPBAppDelegate *)[[UIApplication sharedApplication] delegate] getIconFromIndex:voicePackInfp.voicePackIndex] forState:UIControlStateNormal];
		}
		[btn setAlpha:(w == 0 ? 1 : VOICE_PACK_BUTTON_DISSELECT_ALPHA)];
		[btn setTag:w];
		[btn addTarget:self action:@selector(onVoicePackTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:btn];
		[voicePackList_ addObject:btn];
	}
	
	voicePackIndex_ = (voicePackCount > 0) ? 0 : -1;
	[self selectVoicePackButton:0];
}

- (void)selectVoicePackButton:(NSInteger)index {
	
	voicePackIndex_ = index;
	
	UIButton *btn;
	for (btn in voicePackList_) {
		[btn setAlpha:VOICE_PACK_BUTTON_DISSELECT_ALPHA];
	}
	btn = [voicePackList_ objectAtIndex:index];
	[btn setAlpha:1];

	NSString *msg = VOICE_PACK_MUTE_MESSAGE;
	if (voicePackIndex_ > -1 && (voicePackMuteIndex_ != voicePackIndex_)) {
		VoicePackInfo *vpi = [[self getModels].voicePackCollection getAtIndex:voicePackIndex_];
		msg = vpi.voicePackName;
	}
	voicePackTitleLabel_.text = [msg retain];
}

- (void)changeIndex:(NSUInteger)index {
	BookInfo *bookInfo = [[self getModels].bookCollection getAtIndex:index];
	titleLabel_.text = bookInfo.title;
	authorLabel_.text = bookInfo.author;
	flagImage_.image = [self getFlagFromIOCName:bookInfo.language];
	
	[backButton_ setHidden:(index == 0)];
	[forwardButton_ setHidden:(index == flowView_.numberOfImages - 1)];
	
	[[self getModels].voicePackCollection changeTargetBookByID:bookInfo.bookID];
	[self reloadVoicePackButton];
}

- (void)toRead:(int)index voicePackIndex:(NSInteger)voicePackIndex mother:(BOOL)mother {
	
	BOOL autoFlip = YES;
	BOOL mute = NO;
	if (voicePackMuteIndex_ == voicePackIndex) {
		autoFlip = NO;
		mute = YES;
	}
	NSLog(@"toRead index: %d voicePackIndex: %d autoFlip: %d mute: %d mother: %d", index, voicePackIndex, autoFlip, mute, mother);
	
	BookInfo *bookInfo = [[self getModels].bookCollection getAtIndex:index];
	if (bookInfo) {
		[self playSE:@"select"];

		NSString *directory = [NSString stringWithFormat:@"%@/%@", [Util getLocalDocument], bookInfo.bookID];
		
		VoicePackInfo *voicePackInfo = nil;
		NSString *voicePackDirectory = nil;
		if (voicePackIndex > -1 && !mute) {
			voicePackInfo = [[self getModels].voicePackCollection getAtIndex:voicePackIndex];
			voicePackDirectory = [NSString stringWithFormat:@"%@/%@/%@",
											[Util getLocalDocument],
											bookInfo.bookID,
											voicePackInfo.voicePackID];
		}
		
		readViewController_ = [[ReadViewCtrl alloc] initWithNibName:@"ReadView" bundle:nil];
		[readViewController_ setTitle:bookInfo.title];
		[readViewController_ setup:directory
						selectPage:1
						   pageNum:bookInfo.pageCount
						  fakePage:0
						 direction:bookInfo.direction
						windowMode:MODE_B
				voicePackDirectory:voicePackDirectory
						  autoFlip:autoFlip
							  mute:mute
							mother:mother];
		
		GoodPBAppDelegate *appDelegate = (GoodPBAppDelegate *)[[UIApplication sharedApplication] delegate];
		[appDelegate.navController pushViewController:readViewController_ animated:YES];
	}
	else {
		NSLog(@"[ERROR] toRead bookInfo is nil.");
	}
}

- (UIImage *)getFlagFromIOCName:(NSString *)iocName {
	if ([iocName isEqual:@"JPN"]) {
		return [UIImage imageNamed:@"Japan.png"];
	}
	else if ([iocName isEqual:@"USA"]) {
		return [UIImage imageNamed:@"United-States.png"];
	}
	
	return [UIImage imageNamed:@"Japan.png"];
}

#pragma mark -
#pragma mark Models methods
- (Models *)getModels {
	GoodPBAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	return appDelegate.models;
}

#pragma mark -
#pragma mark Sound Effect methods

- (void)loadSE:(NSString *)soundID soundPath:(NSString *)soundPath {
	GoodPBAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[appDelegate.audioServicesController load:soundID soundPath:soundPath];
}

- (void)playSE:(NSString *)soundID {
	GoodPBAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[appDelegate.audioServicesController play:soundID];
}

#pragma mark -
#pragma mark Events

- (void)onEditVoicePackList:(NSNotification *)notification {
	[self reloadVoicePackButton];
}

- (void)onSelectVoiceOfList:(NSNotification *)notification {
	
	if (popoverController_.popoverVisible) {
		[popoverController_ dismissPopoverAnimated:NO];
	}
	
	NSNumber *row = (NSNumber *)[notification object];
	[self selectVoicePackButton:[row unsignedIntegerValue]];
	[self toRead:flowIndex_ voicePackIndex:voicePackIndex_ mother:YES];
}

- (void)onPushEditVoicePack:(NSNotification *)notification {
	NSNumber *row = (NSNumber *)[notification object];
	VoicePackEditController *ctrl = [[VoicePackEditController alloc] initWithNibName:@"VoicePackEditView" bundle:nil];
	[ctrl setContentSizeForViewInPopover:voicePackViewSize_];
	[navController_ pushViewController:ctrl animated:YES];
	[ctrl setVoiceIndex:[row intValue]];
	[ctrl release];
}

#pragma mark -
#pragma mark IBAction events

- (IBAction)onVoicePackTouchUpInside:(id)sender {
	UIButton *btn = (UIButton *)sender;
	[self selectVoicePackButton:btn.tag];
}

- (IBAction)onFemaleTouchUpInside:(id)sender {
	if (popoverController_.popoverVisible) {
		[popoverController_ dismissPopoverAnimated:YES];
	}
	else {
		BookInfo *bookInfo = [[self getModels].bookCollection getAtIndex:flowIndex_];
		[voicePackSelectController_ reload:bookInfo.bookID];
		[popoverController_ presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
	}
}

- (IBAction)onBackTouchUpInside:(id)sender {
	if (flowIndex_ > 0) {
		flowIndex_--;
		[flowView_ setSelectedCover:flowIndex_];
		[flowView_ centerOnSelectedCover:YES];
		
		[self changeIndex:flowIndex_];
		[self playSE:@"move"];
	}
}

- (IBAction)onForwardTouchUpInside:(id)sender {
	if (flowIndex_ < (flowView_.numberOfImages - 1)) {
		flowIndex_++;
		[flowView_ setSelectedCover:flowIndex_];
		[flowView_ centerOnSelectedCover:YES];
	
		[self changeIndex:flowIndex_];
		[self playSE:@"move"];
	}
}

#pragma mark -
#pragma mark AFOpenFlowView events

- (UIImage *)createCoverUIImage:(NSString *)bookID {
	UIImage *image = [[UIImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/%@/0001.%@",
											   [Util getLocalDocument],
											   bookID,
											   BOOK_FILE_EXTENSION]];
	UIImage *newImage = [Util resizeUIImage:image width:MAX_COVER_WIDTH height:MAX_COVER_HEIGHT aspectFit:YES];
	[image release];
	
	return newImage;
}

- (void)openFlowView:(AFOpenFlowView *)openFlowView selectionDidChange:(int)index {
	flowIndex_ = index;
	[self changeIndex:flowIndex_];
}

- (void)openFlowView:(AFOpenFlowView *)openFlowView selectionDidTaped:(int)index {
	[self toRead:flowIndex_ voicePackIndex:voicePackIndex_ mother:NO];
}

- (void)openFlowView:(AFOpenFlowView *)openFlowView requestImageForIndex:(int)index {
	BookInfo *bookInfo = [[self getModels].bookCollection getAtIndex:index];
	UIImage *image = [self createCoverUIImage:bookInfo.bookID];
	[openFlowView setImage:image forIndex:index];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	if ([viewController isKindOfClass:[VoicePackSelectController class]]) {
		[viewController setContentSizeForViewInPopover:voicePackViewSize_];
	}
	else if (readViewController_ && readViewController_ != viewController) {
		[readViewController_ close];
		[readViewController_ release];
		readViewController_ = nil;
	}
}

- (UIImage *)defaultImage {
	BookInfo *bookInfo = [[self getModels].bookCollection getAtIndex:0];
	return [self createCoverUIImage:bookInfo.bookID];
}

#pragma mark -
#pragma mark PopOverController's navigationController events

@end
