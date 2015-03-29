//
//  NewTripPurposeViewController.m
//  Cycle Atlanta
//
//  Created by Nathaniel Thomas on 3/22/15.
//
//

#import "NewTripPurposeViewController.h"

@interface NewTripPurposeViewController ()

@end

@implementation NewTripPurposeViewController

@synthesize thePicker, cancelBtn, saveBtn, descriptionTextView, navBar, delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    pickerCategories = @[@"Commute", @"School", @"Work Related", @"Exercise", @"Social", @"Shopping", @"Errand", @"Other"];
    
    descriptionArray = @[@"The primary reason for this bike trip is to get between home and your primary work location.", @"The primary reason for this bike trip is to go to or from school or college.", @"The primary reason for this bike trip is to go to or from business-related meeting, function, or work-related errand for your job.",@"The primary reason for this bike trip is exercise or biking for the sake of biking.", @"The primary reason for this bike trip is going to or from a social activity (e.g. at a friend's house, the park, a restaurant, the movies).", @"The primary reason for this bike trip is to purchase or bring home goods or groceries.", @"The primary reason for this bike trip is to attend to personal business such as banking, doctor visit, going to the gym, etc.", @"If none of the other reasons apply to this trip, you can enter trip comments after saving your trip to tell us more."];
    
    imageNames = @[@"commute.png", @"school.png", @"workRelated.png", @"exercise.png", @"social.png", @"shopping.png", @"errands.png", @"other.png"];
    
    // Making the picker and textView more visable.
    thePicker.layer.borderWidth = 1.0;
    thePicker.layer.cornerRadius = 5.0;
    descriptionTextView.layer.borderWidth = 1.0;
    descriptionTextView.layer.cornerRadius = 5.0;
    descriptionTextView.text = [descriptionArray objectAtIndex:0];
    thePicker.backgroundColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor lightGrayColor];
    saveBtn.enabled = YES;

}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component
{
    rowNum = row;
    descriptionTextView.text = descriptionArray[row];
}

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 8;
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    // Runs 8 times. When row is equal to i the title is set
    // to pickerCategories at index i.
    for(int i = 0; i < [pickerCategories count]; i++)
    {
        if(row == i)
        {
            return [pickerCategories objectAtIndex:i];
        }
    }
    
    return nil;
}

// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    int sectionWidth = self.view.frame.size.width;
    
    return sectionWidth;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 50;
}

- (UIView *) pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    if(row < [pickerCategories count])
    {
        tripPickView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 10, tripPickView.frame.size.width - 50, 27)];
        titleLabel.text = [pickerCategories objectAtIndex:row];
        UIImageView *noteAsset = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[imageNames objectAtIndex:row]]];
        [noteAsset setFrame:CGRectMake(0, 10, 46, 27)];
        [tripPickView addSubview:titleLabel];
        [tripPickView addSubview:noteAsset];
        index = 0;
        return tripPickView;
    }
    return nil;
//    else if(row >6)
//    {
//        issueView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
//        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 10, issueView.frame.size.width - 50, 27)];
//        titleLabel.text = [pickerCategories objectAtIndex:row];
//        UIImageView *noteIssue = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noteIssueMapGlyph.png"]];
//        [noteIssue setFrame:CGRectMake(0, 10, 46, 27)];
//        [issueView addSubview:titleLabel];
//        [issueView addSubview:noteIssue];
//        index = 1;
//        return issueView;
//    }
//    else if(row == 6)
//    {
//        startView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
//        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(-140, 10, startView.frame.size.width, 27)];
//        titleLabel.text = @"...";
//        titleLabel.textAlignment = NSTextAlignmentCenter;
//        [startView addSubview:titleLabel];
//        return startView;
//    }
}


-(IBAction)cancelTapped:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    NSLog(@"Cancel Tapped");
}

-(IBAction)saveTapped:(id)sender
{
    NSLog(@"Saved was tapped");
    
    NSLog(@"Purpose Save button pressed");
    //NSInteger row = [customPickerView selectedRowInComponent:0];
    
    TripDetailViewController *tripDetailViewController = [[TripDetailViewController alloc] initWithNibName:@"TripDetailViewController" bundle:nil];
    tripDetailViewController.delegate = self.delegate;
    [delegate didPickPurpose:rowNum];
    
    //rowNum = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickerCategory"];
    //[[NSUserDefaults standardUserDefaults] setInteger:rowNum forKey: @"pickerCategory"];
    //[[NSUserDefaults standardUserDefaults] synchronize];

    
    //[self presentModalViewController:tripDetailViewController animated:YES];
    [self presentViewController:tripDetailViewController animated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
