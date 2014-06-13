// Copyright 2011 ESRI
//
// All rights reserved under the copyright laws of the United States
// and applicable international laws, treaties, and conventions.
//
// You may freely redistribute and use this sample code, with or
// without modification, provided you include the original copyright
// notice and use restrictions.
//
// See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>

@class FeatureTemplatePickerViewController;

/** The delegate that will be notified by FeatureTemplatePickerViewController
 when the user dismisses the controller or picks a template from the list 
 */
@protocol FeatureTemplatePickerDelegate <NSObject>

@optional

-(void)featureTemplatePickerViewControllerWasDismissed: (FeatureTemplatePickerViewController*) featureTemplatePickerViewController;

-(void)featureTemplatePickerViewController:(FeatureTemplatePickerViewController*) featureTemplatePickerViewController didSelectFeatureTemplate:(AGSFeatureTemplate*)template forFeatureLayer:(AGSFeatureLayer*)featureLayer;

@end


@interface FeatureTemplatePickerViewController : UIViewController <UITableViewDataSource,UITableViewDelegate> {
	UITableView* _featureTemplatesTableView;
    id<FeatureTemplatePickerDelegate> _delegate;
    NSMutableArray* _infos;
}

@property (nonatomic, assign) id<FeatureTemplatePickerDelegate> delegate;
@property (nonatomic,retain) IBOutlet UITableView* featureTemplatesTableView;
@property (nonatomic, retain) NSMutableArray* infos;



- (IBAction) dismiss;
- (void) addTemplatesFromLayer:(AGSFeatureLayer*)layer;

@end


/** A value object to hold information about the feature type, template and layer */
@interface FeatureTemplatePickerInfo : NSObject
//{
//@private
//    AGSFeatureType* _featureType;
//    AGSFeatureTemplate* _featureTemplate;
//    AGSFeatureLayer* _featureLayer;
//}

@property (nonatomic, assign) AGSFeatureType* featureType;
@property (nonatomic, assign) AGSFeatureTemplate* featureTemplate;
@property (nonatomic, assign) AGSFeatureLayer* featureLayer;

@end

