//
//  PictureBooksAppDelegate.h
//  PictureBooks
//
//  Created by Yusuke Kikkawa on 10/09/20.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Models.h"
#import "ATAudioServicesController.h"

@interface PictureBooksAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	Models *models_;
	UINavigationController *navController_;
	ATAudioServicesController *audioServicesController_;
	
@private
    NSManagedObjectContext *managedObjectContext_;
    NSManagedObjectModel *managedObjectModel_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;
	NSManagedObject *userinfoManagerdObject_;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navController;
@property (nonatomic, assign) Models *models;
@property (nonatomic, assign) ATAudioServicesController *audioServicesController;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

#pragma mark -
#pragma mark Common methods

- (UIImage *)getIconFromIndex:(NSUInteger)index;

@end

