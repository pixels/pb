//
//  GoodPBAppDelegate.m
//  GoodPB
//
//  Created by Yusuke Kikkawa on 10/09/20.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "Configure.h"
#import "Util.h"
#import "GoodPBAppDelegate.h"

@implementation GoodPBAppDelegate

@synthesize window;
@synthesize navController = navController_;
@synthesize models = models_;
@synthesize audioServicesController = audioServicesController_;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	
#ifdef IPAD
	NSLog(@"Device type is iPad.");
#endif
#ifdef IPHONE
	NSLog(@"Device type is iPhone.");
#endif
	
    // Override point for customization after application launch.
	models_ = [[Models alloc] init];
	audioServicesController_ = [[ATAudioServicesController alloc] init];
	
	NSString * deviceModel = [[UIDevice currentDevice] model];
	NSRange searchResult = [deviceModel rangeOfString:@"iPad"];
	models_.device.iPad = (searchResult.length > 0);
	
	[window addSubview:navController_.view];
    [window makeKeyAndVisible];
	
	return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
}


- (void)applicationWillTerminate:(UIApplication *)application {
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
}


- (void)dealloc {
	[audioServicesController_ release];
	[navController_ release];
	[models_ release];
    [window release];
    [super dealloc];
}

#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    
    if (managedObjectContext_ != nil) {
        return managedObjectContext_;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext_ = [[NSManagedObjectContext alloc] init];
        [managedObjectContext_ setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext_;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel_ != nil) {
        return managedObjectModel_;
    }
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"maindata" ofType:@"momd"];
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
    managedObjectModel_ = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return managedObjectModel_;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (persistentStoreCoordinator_ != nil) {
        return persistentStoreCoordinator_;
    }
    
    NSURL *storeURL = [NSURL fileURLWithPath: [DOCUMENTS_FOLDER stringByAppendingPathComponent: STORE_NAME]];
    
    NSError *error = nil;
    persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return persistentStoreCoordinator_;
}

#pragma mark -
#pragma mark Common methods

- (UIImage *)getIconFromIndex:(NSUInteger)index {
	if (index == 0) {
		return [UIImage imageNamed:@"t9batty_trans.png"];
	}
	else if (index == 1) {
		return [UIImage imageNamed:@"t9dog1_trans.png"];
	}
	else if (index == 2) {
		return [UIImage imageNamed:@"t9dog2_trans.png"];
	}
	else if (index == 3) {
		return [UIImage imageNamed:@"t9ducky_trans.png"];
	}
	else if (index == 4) {
		return [UIImage imageNamed:@"t9elephant_trans.png"];
	}
	else if (index == 5) {
		return [UIImage imageNamed:@"t9foxy_trans.png"];
	}
	else if (index == 6) {
		return [UIImage imageNamed:@"t9kitty_trans.png"];
	}
	else if (index == 7) {
		return [UIImage imageNamed:@"t9lion_trans.png"];
	}
	else if (index == 8) {
		return [UIImage imageNamed:@"t9panda_trans.png"];
	}
	else if (index == 9) {
		return [UIImage imageNamed:@"t9penguin_trans.png"];
	}
	
	return [UIImage imageNamed:@"t9batty.png"];
}

@end
