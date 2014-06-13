//
//  SettingsViewController.h
//  Mobile Reporter
//
//  Created by Danny Hatcher on 9/26/11.
//  Copyright 2011 Esri. All rights reserved.
//

#import <UIKit/UIKit.h>

// Delegate for getting notified when the username or auto-locate values change
@protocol SettingsViewControllerDelegate <NSObject>

-(void)didChangeUserName:(NSString *)string;
-(void)didChangeAutoLocate:(BOOL)value;

@end


@interface SettingsViewController : UIViewController {
    UITextField *userNameTextField;
}


@property (nonatomic, assign) id<SettingsViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UITextField *userNameTextField;

- (IBAction)userNameChanged:(id)sender;
- (IBAction)userNameDidEndOnExit:(id)sender;

- (IBAction)autoLocateChange:(id)sender;
@end
