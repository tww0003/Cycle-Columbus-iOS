//
//  NewPickerViewController.h
//  Fountian City Cycling
//
//  Created by Tyler Williamson on 3/22/15.
//
//

#import <UIKit/UIKit.h>
#import "TripPurposeDelegate.h"
#import "DetailViewController.h"
#import <MapKit/MapKit.h>
@class SavedNotesViewController;

@interface NewPickerViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate>
{
    NSArray *pickerCategories;
    NSArray *descriptionArray;
    
    UIView *assetView;
    UIView *issueView;
    UIView *startView;
    
    id <TripPurposeDelegate> delegate;
    
    int index, rowNum;
    NSInteger pickedNotedType;
    SavedNotesViewController *saveNotes;
    @public
    CLLocation *myLocation;

}

@property (nonatomic, retain) CLLocation *myLocation;
@property (nonatomic, strong) id <TripPurposeDelegate> delegate;
@property (nonatomic, weak) IBOutlet UIPickerView *thePicker;
@property (nonatomic, weak) IBOutlet UITextView *descriptionTextView;
@property (nonatomic, weak) IBOutlet UINavigationBar *navBar;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *cancelBtn;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *saveBtn;

-(void)setLocation: (CLLocation *) theLocation;

@end
