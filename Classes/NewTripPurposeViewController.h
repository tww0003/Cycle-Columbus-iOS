//
//  NewTripPurposeViewController.h
//  Fountain City Cycling
//
//  Created by Tyler Williamson on 3/22/15.
//
//

#import <UIKit/UIKit.h>
#import "TripDetailViewController.h"

@interface NewTripPurposeViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate>
{
    NSArray *pickerCategories;
    NSArray *descriptionArray;
    int index, rowNum;
    NSInteger pickedNotedType;
    NSArray *imageNames;

    UIView *tripPickView;
    int pickerIndex;
    
    id <TripPurposeDelegate> delegate;


}

@property (nonatomic, strong) id <TripPurposeDelegate> delegate;
@property (nonatomic, weak) IBOutlet UIPickerView *thePicker;
@property (nonatomic, weak) IBOutlet UITextView *descriptionTextView;
@property (nonatomic, weak) IBOutlet UINavigationBar *navBar;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *cancelBtn;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *saveBtn;

@end
