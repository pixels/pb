//
//  VoicePackSelectController.m
//  GoodPB
//
//  Created by Yusuke Kikkawa on 10/10/01.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Util.h"
#import "GoodPBAppDelegate.h"
#import "VoicePackSelectController.h"
#import "VoicePackSelectCell.h"
#import "Configure.h"

#define VOICE_PACK_DEFAULT_NAME @"新しいボイスパック"

@interface VoicePackSelectController (InternalMethods)
- (void)setEditing:(BOOL)editing animated:(BOOL)animated;
- (void)onAddTouchUpInside:(id)sender;
@end

@implementation VoicePackSelectController

#pragma mark -
#pragma mark Common methods

- (id)initWithNibNameAndValue:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
//		[self setupAddButton:YES];
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIDeviceOrientationLandscapeLeft || interfaceOrientation == UIDeviceOrientationLandscapeRight);
}

- (void)dealloc {
	if (addButton_) {
		[addButton_ release];
	}
	
	[selectedBookID_ release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self reload:selectedBookID_];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"EDIT_VOICE_PACK_LIST_EVENT" object:nil userInfo:nil];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark -
#pragma mark Models methods
- (Models *)getModels {
	GoodPBAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	return appDelegate.models;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return 1;
	}
    return [[self getModels].voicePackCollection count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return @"";
	}
	return @"ボイスリスト";
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *cell;
	if ([indexPath section] == 0) {
		cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"] autorelease];
			[cell.textLabel setTextAlignment:UITextAlignmentCenter];
			[cell.textLabel setText:@"ボイスパックの追加"];
		}
	}
	else {
		static NSString *CellIdentifier = @"VoicePackSelectCell";
		
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
			cell = [nib objectAtIndex:0];
		}
		[cell setSelected:NO animated:NO];
		
		VoicePackInfo *voicePackInfo = [[self getModels].voicePackCollection getAtIndex:[indexPath row]];
		
		// Configure the cell...
		VoicePackSelectCell *vpscell = (VoicePackSelectCell *)cell;
		[vpscell.imageView setImage:[(GoodPBAppDelegate *)[[UIApplication sharedApplication] delegate] getIconFromIndex:voicePackInfo.voicePackIndex]];
		[vpscell.title setText:voicePackInfo.voicePackName];
		[vpscell.date setText:[voicePackInfo.date description]];
	}
	
	return cell;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		VoicePackInfo *vp = [[self getModels].voicePackCollection getAtIndex:[indexPath row]];
		NSString *directory = [[NSString alloc] initWithFormat:@"%@/BOOK_%@/%@", DOCUMENTS_FOLDER, selectedBookID_, vp.voicePackID];
		[[NSFileManager defaultManager] removeItemAtPath:directory error:nil];
		
        // Delete the row from the data source
		[[self getModels].voicePackCollection removeAtIndex:[indexPath row]];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"EDIT_VOICE_PACK_LIST_EVENT" object:nil userInfo:nil];
//		[self setupAddButton:YES];
    }
}


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	if (fromIndexPath.section == toIndexPath.section) {
        if (toIndexPath.row < [[self getModels].voicePackCollection count]) {
			[[self getModels].voicePackCollection swapIndex:[fromIndexPath row] atIndex:[toIndexPath row]];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"EDIT_VOICE_PACK_LIST_EVENT" object:nil userInfo:nil];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([indexPath section] == 0) {
		return NO;
	}
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([indexPath section] == 0) {
		return NO;
	}
    return YES;
}


#pragma mark -
#pragma mark Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([indexPath section] == 0) {
		return 44;
	}
	
#ifdef IPHONE
	return 64;
#else
	return 80;
#endif
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	if ([indexPath section] == 0) {
		[cell setSelected:NO animated:NO];
		[self onAddTouchUpInside:nil];
	}
	else {
		if (editing_) {
			[self setEditing:NO animated:NO];
			NSNumber *row = [NSNumber numberWithUnsignedInt:[indexPath row]];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"PUSH_EDIT_VOICE_PACK_EVENT" object:row userInfo:nil];
		}
		else {
			NSNumber *row = [NSNumber numberWithUnsignedInt:[indexPath row]];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"SELECT_VOICE_OF_LIST_EVENT" object:row userInfo:nil];
		}
	}
}


#pragma mark -
#pragma mark Methods

- (void)reload:(NSString *)bookID {
	selectedBookID_ = [bookID retain];
	UITableView *tv = (UITableView *)self.view;
	[tv reloadData];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	editing_ = editing;
	UITableView *tv = (UITableView *)self.view;
    [tv setEditing:editing animated:YES];
}

- (void)onEditTouchUpInside {
	UITableView *tv = (UITableView *)self.view;
	[self setEditing:!tv.editing animated:YES];
}

- (void)onAddTouchUpInside:(id)sender {
	NSUInteger count = [[self getModels].voicePackCollection count];
	if (count < MAX_VOICE_PACK) {
		UITableView *tv = (UITableView *)self.view;
		NSDate *date = [NSDate date];
		NSUInteger randSuffix = rand() % 1000;
		NSString *addID = [[NSString alloc] initWithFormat:@"VOICEPACK_%@_%d", [date description], randSuffix];
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:count inSection:1];
		NSArray *indexPaths = [NSArray arrayWithObjects:indexPath,nil];
		NSUInteger randIndex = rand() % 10;
		
		[[self getModels].voicePackCollection addWithValue:addID voicePackName:VOICE_PACK_DEFAULT_NAME bookID:selectedBookID_ voicePackIndex:randIndex date:date owner:YES];
		[tv insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
		
		NSString *directory = [[NSString alloc] initWithFormat:@"%@/%@/%@", DOCUMENTS_FOLDER, selectedBookID_, addID];
		[[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"EDIT_VOICE_PACK_LIST_EVENT" object:nil userInfo:nil];
	}
	else {
		NSLog(@"Voice pack is max!!!");
//		[self setupAddButton:NO];
	}
}

@end

