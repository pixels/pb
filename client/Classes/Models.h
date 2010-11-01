//
//  Models.h
//  PictureBooks
//
//  Created by kikkawa on 10/10/04.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BookInfo.h"
#import "BookCollection.h"
#import "VoicePackInfo.h"
#import "VoicePackCollection.h"

@interface Models : NSObject {
	BookCollection *bookCollection_;
	VoicePackCollection *voicePackCollection_;
}

@property (nonatomic, assign) BookCollection *bookCollection;
@property (nonatomic, assign) VoicePackCollection *voicePackCollection;

@end
