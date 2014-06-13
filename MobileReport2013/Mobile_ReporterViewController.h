//
//  Mobile_ReporterViewController.h
//  Mobile Reporter
//
//  Created by Danny Hatcher on 9/23/11.
//  Copyright 2011 Esri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>
#import "SettingsViewController.h"
#import "FeatureTemplatePickerViewController.h"
#import "LoadingView.h"

@interface Mobile_ReporterViewController : UIViewController<AGSWebMapDelegate, SettingsViewControllerDelegate, AGSQueryTaskDelegate, AGSPopupsContainerDelegate, FeatureTemplatePickerDelegate, AGSMapViewTouchDelegate, AGSAttachmentManagerDelegate, AGSMapViewCalloutDelegate, AGSMapViewLayerDelegate, AGSFeatureLayerEditingDelegate> {
    
    bool _isGPSRunning;
    AGSGraphic *_newFeature;
    UIBarButtonItem *sketchCompleteButton;
    UIToolbar *topToolbar;
    UIBarButtonItem *reportButtonNew;
    UIView *bannerView;
    UIBarButtonItem *polygonNoteButton;
    UIBarButtonItem *sketchComplete;
    UIBarButtonItem *createNewPolygon;
}


@property (nonatomic, retain) IBOutlet AGSMapView *mapView;
@property (nonatomic, retain) AGSWebMap *webMapMR;
@property (nonatomic, retain) SettingsViewController *settingsViewController;
@property (nonatomic, retain) UIPopoverController *settingsPopoverController;
@property (nonatomic, retain) AGSFeatureLayer *mobileResourceLayer;
@property (nonatomic, retain) AGSFeatureLayer *reportingLayer;
@property (nonatomic, retain) AGSFeatureLayer *polygonLayer;
@property (nonatomic, retain) NSTimer *checkInTimer;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) AGSQueryTask *resourceQueryTask;
@property (nonatomic, retain) AGSPopupsContainerViewController *popupsViewController;
@property (nonatomic, retain) FeatureTemplatePickerViewController *featureTemplatePickerViewController;
@property (nonatomic, retain) AGSSketchGraphicsLayer *sketchLayer;
@property (nonatomic, retain) AGSFeatureLayer *activeFeatureLayer;
@property (nonatomic, retain) LoadingView *loadingView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *sketchCompleteButton;
@property (nonatomic, retain) IBOutlet UIToolbar *topToolbar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *reportButtonNew;
@property (nonatomic, retain) IBOutlet UIView *bannerView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *polygonNoteButton;


- (IBAction)gpsPressed:(id)sender;
- (IBAction)createNewReport:(id)sender;
- (IBAction)checkIn:(id)sender;
- (IBAction)settingsPressed:(id)sender;
- (IBAction)sketchComplete:(id)sender;
- (IBAction)createNewPolygon:(id)sender;


- (void)checkInTimerFired:(NSTimer*)theTimer;


@end
