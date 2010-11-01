//
//  Queue.h
//  iNocco
//
//  Created by kikkawa on 10/08/12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Queue : NSMutableArray {
}

- (id) dequeue;
- (void) enqueue:(id)obj;

@end
