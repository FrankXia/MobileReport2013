//
//  SettingsViewController.m
//  Mobile Reporter
//
//  Created by Danny Hatcher on 9/26/11.
//  Copyright 2011 Esri. All rights reserved.
//

#import "SettingsViewController.h"

@implementation SettingsViewController
@synthesize userNameTextField;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setUserNameTextField:nil];
    [self setDelegate:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}


- (IBAction)userNameChanged:(id)sender {
    [self.delegate didChangeUserName:self.userNameTextField.text];
}

- (IBAction)userNameDidEndOnExit:(id)sender {
}

- (IBAction)autoLocateChange:(id)sender {
    UISwitch *autoLocateSwitch = (UISwitch *)sender;
    
    [self.delegate didChangeAutoLocate:autoLocateSwitch.isOn];
}
@end
