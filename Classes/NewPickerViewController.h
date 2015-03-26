//
//  NewPickerViewController.h
//  Cycle Atlanta
//
//  Created by Nathaniel Thomas on 3/22/15.
//
//

#import <UIKit/UIKit.h>
#import "TripPurposeDelegate.h"
#import "DetailViewController.h"

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
}

@property (nonatomic, strong) id <TripPurposeDelegate> delegate;
@property (nonatomic, weak) IBOutlet UIPickerView *thePicker;
@property (nonatomic, weak) IBOutlet UITextView *descriptionTextView;
@property (nonatomic, weak) IBOutlet UINavigationBar *navBar;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *cancelBtn;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *saveBtn;

@end
