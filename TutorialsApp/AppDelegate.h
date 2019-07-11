//
//  AppDelegate.h
//  TutorialsApp
//
//  Created by mohamed saeed on 7/10/19.
//  Copyright © 2019 mohamed saeed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

