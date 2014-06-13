//
//  OfflineEditingAppDelegate.h
//  MobileReport2013
//
//  Created by Frank on 3/13/13.
//  Copyright (c) 2013 Esri. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OfflineEditingViewController;
@class Mobile_ReporterViewController;

@interface OfflineEditingAppDelegate : UIResponder <UIApplicationDelegate>

//@property (strong, nonatomic) UIWindow *window;
//
//@property (strong, nonatomic) OfflineEditingViewController *viewController;

@property (nonatomic, retain) UIWindow *window;

@property (nonatomic, retain) Mobile_ReporterViewController *viewController;

@end
