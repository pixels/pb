//
//  VoicePackSelectCell.h
//  PictureBooks
//
//  Created by Yusuke Kikkawa on 10/10/01.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface VoicePackSelectCell : UITableViewCell {
	UIImageView *imageView_;
	UILabel *title_;
	UILabel *date_;
}

@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UILabel *title;
@property (nonatomic, retain) IBOutlet UILabel *date;

@end
