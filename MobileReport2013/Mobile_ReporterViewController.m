//
//  Mobile_ReporterViewController.m
//  Mobile Reporter
//
//  Created by Danny Hatcher on 9/23/11.
//  Copyright 2011 Esri. All rights reserved.
//

#import "Mobile_ReporterViewController.h"

@implementation Mobile_ReporterViewController
@synthesize mapView;
@synthesize webMapMR;
@synthesize settingsViewController;
@synthesize settingsPopoverController;
@synthesize mobileResourceLayer;
@synthesize reportingLayer;
@synthesize polygonLayer;
@synthesize checkInTimer;
@synthesize username;
@synthesize resourceQueryTask;
@synthesize popupsViewController;
@synthesize featureTemplatePickerViewController;
@synthesize sketchLayer;
@synthesize activeFeatureLayer;
@synthesize sketchCompleteButton;
@synthesize topToolbar;
@synthesize reportButtonNew;
@synthesize bannerView;
@synthesize polygonNoteButton;
@synthesize loadingView;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (IBAction)sketchComplete:(id)sender{
    //self.navigationItem.rightBarButtonItem = self.pickTemplateButton;
    [self presentModalViewController:self.popupsViewController animated:YES];
    self.mapView.touchDelegate = self;
    //self.sketchCompleteButton.enabled = NO;
    NSMutableArray *barItems = [self.topToolbar.items mutableCopy];
    [barItems removeObject:self.sketchCompleteButton];
    [barItems addObject:self.polygonNoteButton];
    [barItems addObject:self.reportButtonNew];
    self.topToolbar.items = barItems;
    self.bannerView.hidden = YES;
    
    
}


-(void)presentFeatureTemplatePicker{
    //We don't want it to cover the entire screen
    self.featureTemplatePickerViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    //Animate vertically on both iPhone & iPad
    self.featureTemplatePickerViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    //Present
    [self presentModalViewController:self.featureTemplatePickerViewController animated:YES];
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set the client ID, updated on June 12, 2014. Also fixed two compilation error casued by iOS 6 code
    NSError *error;
    NSString* clientID = @"coaparJFEHBn5lqs";
    [AGSRuntimeEnvironment setClientID:clientID error:&error];
    if(error){
        // We had a problem using our client ID
        NSLog(@"Error using client ID : %@",[error localizedDescription]);
    }
    
    //Initialize the feature template picker so that we can show it later when needed
    self.featureTemplatePickerViewController =  [[FeatureTemplatePickerViewController alloc] initWithNibName:@"FeatureTemplatePickerViewController" bundle:nil];
    self.featureTemplatePickerViewController.delegate = self;
    
    // setup the top toolbar buttons correctly
    NSMutableArray *barItems = [self.topToolbar.items mutableCopy];
    [barItems removeObject:self.sketchCompleteButton];
    self.topToolbar.items = barItems;
    
    _isGPSRunning = NO;
    
    // setup map
    self.mapView.layerDelegate = self;
	self.mapView.touchDelegate = self;
	self.mapView.calloutDelegate = self;
    self.mapView.showMagnifierOnTapAndHold = YES;
    
    //AGSCredential *credential = [[[AGSCredential alloc] initWithUser:@"user" password:@"password"]autorelease];
    //credential.authType = AGSAuthenticationTypeToken;
    self.webMapMR = [AGSWebMap webMapWithItemId:@"321c4557c07840a6935a269add5eabaf" credential:nil];
    
    self.webMapMR.delegate = self;
    [self.webMapMR openIntoMapView:self.mapView];
    
    self.settingsViewController = [[SettingsViewController alloc] init];
    self.settingsPopoverController = [[UIPopoverController alloc] initWithContentViewController:self.settingsViewController];
    self.settingsPopoverController.popoverContentSize = CGSizeMake(250, 133);
    self.settingsViewController.delegate = self;

}


- (void)viewDidUnload
{
    [self setMapView:nil];
    [self setWebMapMR:nil];
    [self setSettingsViewController:nil];
    [self setSettingsPopoverController:nil];
    [self setMobileResourceLayer:nil];
    [self setReportingLayer:nil];
    [self setCheckInTimer:nil];
    [self setUsername:nil];
    [self setResourceQueryTask:nil];
    [self setPopupsViewController:nil];
    [self setFeatureTemplatePickerViewController:nil];
    [self setSketchLayer:nil];
    [self setActiveFeatureLayer:nil];
    [self setSketchCompleteButton:nil];
    [self setTopToolbar:nil];
    [self setReportButtonNew:nil];
    [self setBannerView:nil];
    [self setLoadingView:nil];
    [self setPolygonNoteButton:nil];
    [self setPolygonLayer:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (IBAction)gpsPressed:(id)sender {
    if (_isGPSRunning) {
        [self.mapView.locationDisplay stopDataSource];
    } else {
        self.mapView.locationDisplay.autoPanMode = AGSLocationDisplayAutoPanModeDefault;
        [self.mapView.locationDisplay startDataSource];
    }
    _isGPSRunning = !_isGPSRunning;
}

- (IBAction)createNewPolygon:(id)sender {
    self.activeFeatureLayer = self.polygonLayer;
    //set the feature layer as its infoTemplateDelegate 
    //this will then automatically set the callout's title to a value
    //from the display field of the feature service
    self.activeFeatureLayer.infoTemplateDelegate = self.polygonLayer;
    
    //Get all the fields
    self.activeFeatureLayer.outFields = [NSArray arrayWithObject:@"*"];
    
    //This view controller should be notified when features are edited
    self.activeFeatureLayer.editingDelegate = self;
    
    //Add templates from this layer to the Feature Template Picker
    [self.featureTemplatePickerViewController addTemplatesFromLayer:self.activeFeatureLayer];
    
    // open popup for editing/creating a new feature
    self.featureTemplatePickerViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    //Animate vertically on both iPhone & iPad
    self.featureTemplatePickerViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    //Present
    [self presentModalViewController:self.featureTemplatePickerViewController animated:YES];
}

- (IBAction)createNewReport:(id)sender {
    self.activeFeatureLayer = self.reportingLayer;
    //set the feature layer as its infoTemplateDelegate 
    //this will then automatically set the callout's title to a value
    //from the display field of the feature service
    self.activeFeatureLayer.infoTemplateDelegate = self.reportingLayer;
    
    //Get all the fields
    self.activeFeatureLayer.outFields = [NSArray arrayWithObject:@"*"];
    
    //This view controller should be notified when features are edited
    self.activeFeatureLayer.editingDelegate = self;
    
    //Add templates from this layer to the Feature Template Picker
    [self.featureTemplatePickerViewController addTemplatesFromLayer:self.activeFeatureLayer];
    
    // open popup for editing/creating a new feature
    self.featureTemplatePickerViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    //Animate vertically on both iPhone & iPad
    self.featureTemplatePickerViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    //Present
    [self presentModalViewController:self.featureTemplatePickerViewController animated:YES];
}

- (IBAction)checkIn:(id)sender {
    // create/update the blue force feature for this device
    if (nil == self.username) {
        UIAlertView *noUserAlert = [[UIAlertView alloc] initWithTitle:@"No User Name" message:@"Please provide a user name in settings." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [noUserAlert show];
    } else if (!self.mapView.locationDisplay.dataSourceStarted) {
        UIAlertView *noUserAlert = [[UIAlertView alloc] initWithTitle:@"No GPS Signal" message:@"Please activate GPS to Check In." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [noUserAlert show];
    } else {
        // first query the resource layer to see if this user/device is already listed.
        self.resourceQueryTask = [AGSQueryTask queryTaskWithURL:self.mobileResourceLayer.URL];
        AGSQuery *resourceQuery = [AGSQuery query];
        resourceQuery.outFields = [NSArray arrayWithObject:@"*"];
        resourceQuery.where = [NSString stringWithFormat:@"UDID = '%@' AND Name = '%@'", [[UIDevice currentDevice] identifierForVendor], self.username];
        
        self.resourceQueryTask.delegate = self;
        [self.resourceQueryTask executeWithQuery:resourceQuery];
    }
}

- (IBAction)settingsPressed:(id)sender {
    // open the popup view for the settings
    if (self.settingsPopoverController.isPopoverVisible) {
        [self.settingsPopoverController dismissPopoverAnimated:YES];
    } else {
        [self.settingsPopoverController presentPopoverFromBarButtonItem:(UIBarButtonItem *)sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}



- (void)checkInTimerFired:(NSTimer*)theTimer {
    [self checkIn:nil];
}

#pragma mark AGSQueryTaskDelegate

- (void)queryTask:(AGSQueryTask *)queryTask operation:(NSOperation *)op didExecuteWithFeatureSetResult:(AGSFeatureSet *)featureSet {
    // handle query of resources to see if the current user-device combination is already in database
    AGSGraphic *deviceGraphic = nil;
    
    if ([featureSet.features count] > 0) {
        deviceGraphic = [featureSet.features objectAtIndex:0];
    }
    
    if (nil != deviceGraphic) {
        // update this existing graphic
        deviceGraphic.geometry = self.mapView.locationDisplay.mapLocation;
        [deviceGraphic.allAttributes setValue:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970] * 1000.00] forKey:@"LastCheckin"];
        [self.mobileResourceLayer updateFeatures:[NSArray arrayWithObject:deviceGraphic]];
    } else {
        // create a new feature.
        AGSFeatureType *fieldType = [self.mobileResourceLayer.types objectAtIndex:2];
        deviceGraphic = [self.mobileResourceLayer featureWithType:fieldType];
        deviceGraphic.geometry = self.mapView.locationDisplay.mapLocation;
        [deviceGraphic.allAttributes setValue:[[UIDevice currentDevice] identifierForVendor] forKey:@"UDID"];
        [deviceGraphic.allAttributes setValue:self.username forKey:@"Name"];
        [deviceGraphic.allAttributes setValue:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970] * 1000.00] forKey:@"LastCheckin"];
        [self.mobileResourceLayer addFeatures:[NSArray arrayWithObject:deviceGraphic]];
    }
}

- (void)queryTask:(AGSQueryTask *)queryTask operation:(NSOperation *)op didFailWithError:(NSError *)error {
    
}
    

#pragma mark SettingsViewControllerDelegate

- (void)didChangeAutoLocate:(BOOL)value {
    if (value) {
        // crank up check in timer
        self.checkInTimer = [NSTimer scheduledTimerWithTimeInterval:20.0
                                                    target:self 
                                                  selector:@selector(checkInTimerFired:) 
                                                  userInfo:nil 
                                                   repeats:YES];
    } else {
        // invalidate check in timer
        [self.checkInTimer invalidate];
        self.checkInTimer = nil;
    }
}

- (void)didChangeUserName:(NSString *)string {
    self.username = string;
}

#pragma mark - AGSWebMapDelegate methods

- (void)didLoadLayer:(AGSLayer *) layer {
    
    //The last feature layer we encounter we will use for editing features
    //If the web map contains more than one feature layer, the sample may need to be modified to handle that
    if([layer isKindOfClass:[AGSFeatureLayer class]]){
        
        if ([layer.name isEqualToString:@"MobileReporting - Mobile Resources"]) {
            self.mobileResourceLayer = (AGSFeatureLayer *)layer;
        } else if ([layer.name isEqualToString:@"MobileReporting - Field Report"]) {
            self.reportingLayer = (AGSFeatureLayer *)layer;
            
        } else if ([layer.name isEqualToString:@"MobileReporting - Field Note"]) {
            self.polygonLayer = (AGSFeatureLayer *)layer;

        }
    }
}

- (void) didFailToLoadLayer:(NSString *)layerTitle withError:(NSError *)error {
    [self.webMapMR continueOpenAndSkipCurrentLayer];
}

- (void)didOpenWebMap:(AGSWebMap *) webMap intoMapView:(AGSMapView *) mapView {
    //Once all the layers in the web map are loaded
    //we will add a dormant sketch layer on top. We will activate the sketch layer when the time is right.
    self.sketchLayer = [[AGSSketchGraphicsLayer alloc] init];
    [self.mapView addMapLayer:self.sketchLayer withName:@"Sketch Layer"];
    //register self for receiving notifications from the sketch layer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToGeomChanged:) name:@"GeometryChanged" object:nil];
}

#pragma mark -
#pragma mark AGSSketchGraphicsLayer notifications
- (void)respondToGeomChanged: (NSNotification*) notification {
    //Check if the sketch geometry is valid to decide whether to enable
    //the sketchCompleteButton
    if([self.sketchLayer.geometry isValid] && ![self.sketchLayer.geometry isEmpty]) {
        NSMutableArray *barItems = [self.topToolbar.items mutableCopy];
        [barItems removeObject:self.reportButtonNew];
        [barItems removeObject:self.polygonNoteButton];
        [barItems addObject:self.sketchCompleteButton];
        self.topToolbar.items = barItems;
    }
        
    // Probably need to implement this in some way.
    
}


#pragma mark - FeatureTemplatePickerDelegate methods

-(void)featureTemplatePickerViewControllerWasDismissed: (FeatureTemplatePickerViewController*) featureTemplatePickerViewController{
    [self dismissModalViewControllerAnimated:YES];
}


-(void)featureTemplatePickerViewController:(FeatureTemplatePickerViewController*) featureTemplatePickerViewController didSelectFeatureTemplate:(AGSFeatureTemplate*)template forFeatureLayer:(AGSFeatureLayer*)featureLayer{
    
    
    //create a new feature based on the template
    _newFeature = [self.activeFeatureLayer featureWithTemplate:template];
    
    //Add the new feature to the feature layer's graphic collection
    //This is important because then the popup view controller will be able to 
    //find the feature layer associated with the graphic and inspect the field metadata
    //such as domains, subtypes, data type, length, etc
    //Also note, if the user cancels before saving the new feature to the server, 
    //we will manually need to remove this
    //feature from the feature layer (see implementation for popupsContainer:didCancelEditingGraphicForPopup: below)
    [self.activeFeatureLayer addGraphic:_newFeature];
    
    //Iniitalize a popup view controller
    self.popupsViewController = [[AGSPopupsContainerViewController alloc] initWithWebMap:self.webMapMR forFeature:_newFeature usingNavigationControllerStack:NO];
    self.popupsViewController.delegate = self;
    
    self.popupsViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    //Animate by flipping horizontally
    self.popupsViewController.modalTransitionStyle =  UIModalTransitionStyleFlipHorizontal;
    
    //First, dismiss the Feature Template Picker
    [self dismissModalViewControllerAnimated:NO];
    
    //Next, Present the popup view controller
    [self presentModalViewController:self.popupsViewController animated:YES];
    [self.popupsViewController startEditingCurrentPopup];
    
}

#pragma mark - AGSMapViewCalloutDelegate methods

- (BOOL)mapView:(AGSMapView *) mapView shouldShowCalloutForGraphic:(AGSGraphic *) graphic {
    //Dont show callout when the sketch layer is active. 
    //The user is sketching and even if he taps on a feature, 
    //we don't want to display the callout and interfere with the sketching workflow
    return self.mapView.touchDelegate != self.sketchLayer ;
}

-(void)mapView:(AGSMapView *)mapView didClickCalloutAccessoryButtonForGraphic:(AGSGraphic *)graphic{
    
    self.activeFeatureLayer = (AGSFeatureLayer*) graphic.layer;
    //Show popup for the graphic because the user tapped on the callout accessory button
    self.popupsViewController = [[AGSPopupsContainerViewController alloc] initWithWebMap:self.webMapMR forFeature:graphic usingNavigationControllerStack:NO];
    self.popupsViewController.delegate = self;
    self.popupsViewController.modalTransitionStyle =  UIModalTransitionStyleFlipHorizontal;

    self.popupsViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:self.popupsViewController animated:YES];
    
}

- (void)mapView:(AGSMapView *)mapView didShowCalloutForGraphic:(AGSGraphic *)graphic {
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/yyyy hh:mma"];
    NSString *dateString; 
    

    if (graphic.layer == self.reportingLayer) {
        self.mapView.callout.title = [NSString stringWithFormat:@"%@ Report", [graphic.allAttributes valueForKey:@"TYPE"]];
        double timeSince1970 = [[graphic.allAttributes objectForKey:@"REPORTEDAT"] doubleValue] / 1000.0;
        NSDate *reportDate = [NSDate dateWithTimeIntervalSince1970:timeSince1970];
        dateString = [dateFormat stringFromDate:reportDate];
        self.mapView.callout.detail = dateString;
        UIImage *swatch = [self.reportingLayer.renderer swatchForGraphic:graphic size:CGSizeMake(30, 30)];
        self.mapView.callout.image = swatch;

    } else if (graphic.layer == self.mobileResourceLayer) {
        self.mapView.callout.title = (NSString *)[graphic.allAttributes valueForKey:@"Name"];
        double timeSince1970 = [[graphic.allAttributes objectForKey:@"LastCheckin"] doubleValue] / 1000.0;
        NSDate *checkinDate = [NSDate dateWithTimeIntervalSince1970:timeSince1970];
        dateString = [dateFormat stringFromDate:checkinDate];
        self.mapView.callout.detail = dateString;
        UIImage *swatch = [self.mobileResourceLayer.renderer swatchForGraphic:graphic size:CGSizeMake(30, 30)];
        self.mapView.callout.image = swatch;
    } else if (graphic.layer == self.polygonLayer) {
        self.mapView.callout.title = (NSString *)[graphic.allAttributes valueForKey:@"NAME"];
        double timeSince1970 = [[graphic.allAttributes objectForKey:@"REPORTEDON"] doubleValue] / 1000.0;
        NSDate *checkinDate = [NSDate dateWithTimeIntervalSince1970:timeSince1970];
        dateString = [dateFormat stringFromDate:checkinDate];
        self.mapView.callout.detail = dateString;
        UIImage *swatch = [self.polygonLayer.renderer swatchForGraphic:graphic size:CGSizeMake(30, 30)];
        self.mapView.callout.image = swatch;
    }
}



#pragma mark -  AGSPopupsContainerDelegate methods

- (AGSGeometry *)popupsContainer:(id) popupsContainer wantsNewMutableGeometryForPopup:(AGSPopup *) popup {
    //Return an empty mutable geometry of the type that our feature layer uses
    return AGSMutableGeometryFromType( ((AGSFeatureLayer*)popup.graphic.layer).geometryType, self.mapView.spatialReference);
}

- (void)popupsContainer:(id) popupsContainer readyToEditGraphicGeometry:(AGSGeometry *) geometry forPopup:(AGSPopup *) popup{
    //Dismiss the popup view controller
    [self dismissModalViewControllerAnimated:YES];
    
    //Prepare the current view controller for sketch mode
    self.bannerView.hidden = NO;
    self.mapView.touchDelegate = self.sketchLayer; //activate the sketch layer
    self.mapView.callout.hidden = YES;
    
    //Assign the sketch layer the geometry that is being passed to us for 
    //the active popup's graphic. This is the starting point of the sketch
    self.sketchLayer.geometry = geometry;
    
    
    //zoom to the existing feature's geometry
    AGSEnvelope* env = nil;
    AGSGeometryType geoType = AGSGeometryTypeForGeometry(self.sketchLayer.geometry);
    if(geoType == AGSGeometryTypePolygon){
        env = ((AGSPolygon*)self.sketchLayer.geometry).envelope;
    }else if(geoType == AGSGeometryTypePolyline){
        env = ((AGSPolyline*)self.sketchLayer.geometry).envelope ;
    }
    
    // TODO: Update this to test for nan on x/y min/max
//    if(env!=nil){
//        AGSMutableEnvelope* mutableEnv  = [[env mutableCopy] autorelease];
//        [mutableEnv expandByFactor:1.4];
//        [self.mapView zoomToEnvelope:mutableEnv animated:YES];
//    }
    
    //replace the button in the navigation bar to allow a user to 
    //indicate that the sketch is done
    //self.sketchCompleteButton.enabled = NO;
    NSMutableArray *barItems = [self.topToolbar.items mutableCopy];
    [barItems removeObject:self.sketchCompleteButton];
    [barItems addObject:self.polygonNoteButton];
    [barItems addObject:self.reportButtonNew];
    self.topToolbar.items = barItems;
}

- (void)popupsContainer:(id<AGSPopupsContainer>) popupsContainer wantsToDeleteGraphicForPopup:(AGSPopup *) popup {
    //Call method on feature layer to delete the feature
    NSNumber* number = [NSNumber numberWithInteger: [self.activeFeatureLayer objectIdForFeature:popup.graphic]];
    NSArray* oids = [NSArray arrayWithObject: number ];
    [self.activeFeatureLayer deleteFeaturesWithObjectIds:oids ];
    self.loadingView = [LoadingView loadingViewInView:self.popupsViewController.view withText:@"Deleting feature..."];
    
}

-(void)popupsContainer:(id<AGSPopupsContainer>)popupsContainer didFinishEditingGraphicForPopup:(AGSPopup*)popup{
	// simplify the geometry, this will take care of self intersecting polygons and 
	popup.graphic.geometry = [[AGSGeometryEngine defaultGeometryEngine]simplifyGeometry:popup.graphic.geometry];
    //normalize the geometry, this will take care of geometries that extend beyone the dateline 
    //(ifwraparound was enabled on the map)
	popup.graphic.geometry = [[AGSGeometryEngine defaultGeometryEngine]normalizeCentralMeridianOfGeometry:popup.graphic.geometry];
	
    
	int oid = [self.activeFeatureLayer objectIdForFeature:popup.graphic];
	
	if (oid > 0){
		//feature has a valid objectid, this means it exists on the server
        //and we simply update the exisiting feature
		[self.activeFeatureLayer updateFeatures:[NSArray arrayWithObject:popup.graphic]];
	} else {
		//objectid does not exist, this means we need to add it as a new feature
		[self.activeFeatureLayer addFeatures:[NSArray arrayWithObject:popup.graphic]];
	}
    
    //Tell the user edits are being saved int the background
    self.loadingView = [LoadingView loadingViewInView:self.popupsViewController.view withText:@"Saving feature details..."];
    
    //we will wait to post attachments till when the updates succeed
}

- (void)popupsContainerDidFinishViewingPopups:(id) popupsContainer {
    //dismiss the popups view controller
    [self dismissModalViewControllerAnimated:YES];
    self.popupsViewController = nil;
}

- (void)popupsContainer:(id) popupsContainer didCancelEditingGraphicForPopup:(AGSPopup *) popup {
    //dismiss the popups view controller
    [self dismissModalViewControllerAnimated:YES];
    
    //if we had begun adding a new feature, remove it from the layer because the user hit cancel.
    if(_newFeature!=nil){
        [self.activeFeatureLayer removeGraphic:_newFeature];
        _newFeature = nil;
    }
    
    //reset any sketch related changes we made to our main view controller
    [self.sketchLayer clear];
    self.mapView.touchDelegate = self;
    self.mapView.calloutDelegate = self;
    self.bannerView.hidden = YES;
    self.popupsViewController = nil;
}

#pragma mark - 
- (void) warnUserOfErrorWithMessage:(NSString*) message {
    //Display an alert to the user  
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
    
    //Restart editing the popup so that the user can attempt to save again
    [self.popupsViewController startEditingCurrentPopup];
}

#pragma mark - AGSFeatureLayerEditingDelegate methods

-(void)featureLayer:(AGSFeatureLayer *)featureLayer operation:(NSOperation *)op didFeatureEditsWithResults:(AGSFeatureLayerEditResults *)editResults{
    
    //Remove the activity indicator
    [self.loadingView removeView];
    
    //We will assume we have to update the attachments unless
    //1) We were adding a feature and it failed
    //2) We were updating a feature and it failed
    //3) We were deleting a feature
    BOOL _updateAttachments = YES;
    
    if([editResults.addResults count]>0){
        //we were adding a new feature
        AGSEditResult* result = (AGSEditResult*)[editResults.addResults objectAtIndex:0];
        if(!result.success){
            //Add operation failed. We will not update attachments
            _updateAttachments = NO;
            //Inform user
            [self warnUserOfErrorWithMessage:@"Could not add feature. Please try again"];
        }
        
    }else if([editResults.updateResults count]>0){
        //we were updating a feature
        AGSEditResult* result = (AGSEditResult*)[editResults.updateResults objectAtIndex:0];
        if(!result.success){
            //Update operation failed. We will not update attachments
            _updateAttachments = NO;
            //Inform user
            [self warnUserOfErrorWithMessage:@"Could not update feature. Please try again"];
        }
    }else if([editResults.deleteResults count]>0){
        //we were deleting a feature
        _updateAttachments = NO;
        AGSEditResult* result = (AGSEditResult*)[editResults.deleteResults objectAtIndex:0];
        if(!result.success){
            //Delete operation failed. Inform user
            [self warnUserOfErrorWithMessage:@"Could not delete feature. Please try again"];
        }else{
            //Delete operation succeeded
            //Dismiss the popup view controller and hide the callout which may have been shown for
            //the deleted feature.
            self.mapView.callout.hidden = YES;
            [self dismissModalViewControllerAnimated:YES];
            self.popupsViewController = nil;
        }
        
    }
    
    //if edits pertaining to the feature were successful...
    if (_updateAttachments){
        
        [self.sketchLayer clear];
        
        //...we post edits to the attachments 
		AGSAttachmentManager *attMgr = [featureLayer attachmentManagerForFeature:self.popupsViewController.currentPopup.graphic];
		attMgr.delegate = self;
        
        if([attMgr hasLocalEdits]){
			[attMgr postLocalEditsToServer];
            self.loadingView = [LoadingView loadingViewInView:self.popupsViewController.view withText:@"Saving feature attachments..."];
        }  
	}   
}

-(void)featureLayer:(AGSFeatureLayer *)featureLayer operation:(NSOperation *)op didFailFeatureEditsWithError:(NSError *)error{
    NSLog(@"Could not commit edits because: %@", [error localizedDescription]);
    
    [self.loadingView removeView];
    [self warnUserOfErrorWithMessage:@"Could not save edits. Please try again"];
}



#pragma mark -
#pragma mark AGSAttachmentManagerDelegate

-(void)attachmentManager:(AGSAttachmentManager *)attachmentManager didPostLocalEditsToServer:(NSArray *)attachmentsPosted{
    
    [self.loadingView removeView];
    
    //loop through all attachments looking for failures
    BOOL _anyFailure = NO;
    for (AGSAttachment* attachment in attachmentsPosted) {
        if(attachment.networkError!=nil || attachment.editResultError!=nil){
            _anyFailure = YES;
            NSString* reason;
            if(attachment.networkError!=nil)
                reason = [attachment.networkError localizedDescription];
            else if(attachment.editResultError !=nil)
                reason = attachment.editResultError.errorDescription;
            NSLog(@"Attachment '%@' could not be synced with server because %@",attachment.attachmentInfo.name,reason);
        }
    }
    
    if(_anyFailure){
        [self warnUserOfErrorWithMessage:@"Some attachment edits could not be synced with the server. Please try again"];
    }
}

@end
