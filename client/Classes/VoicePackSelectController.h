//
//  VoicePackSelectController.h
//  GoodPB
//
//  Created by Yusuke Kikkawa on 10/10/01.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface VoicePackSelectController : UITableViewController {
	NSString *selectedBookID_;
	UIBarButtonItem *addButton_;
	BOOL editing_;
}

- (id)initWithNibNameAndValue:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
- (void)reload:(NSString *)bookID;
- (void)setupAddButton:(BOOL)visible;

@end
