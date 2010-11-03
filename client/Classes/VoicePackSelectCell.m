//
//  VoicePackSelectCell.m
//  GoodPB
//
//  Created by Yusuke Kikkawa on 10/10/01.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "VoicePackSelectCell.h"


@implementation VoicePackSelectCell
@synthesize imageView = imageView_;
@synthesize title = title_;
@synthesize date = date_;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
	[imageView_ release];
	[title_ release];
	[date_ release];
    [super dealloc];
}


@end
