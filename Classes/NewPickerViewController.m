//
//  NewPickerViewController.m
//  Cycle Atlanta
//
//  Created by Nathaniel Thomas on 3/22/15.
//
//
//  The old class for this was not working correctly.
//  It could be that I'm stupid, but I was having a hard
//  time reading the code while trying to pin point the cause
//  of a bug, so I figured it'd be easier to just rewrite it.

#import "NewPickerViewController.h"

@interface NewPickerViewController ()

@end

@implementation NewPickerViewController

@synthesize thePicker, descriptionTextView, navBar, saveBtn, cancelBtn, delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // All the categories of the picker. 0 - 5 should have a blue astric, 7 - 12 should have a red astric
    
    // Need to add "Parks", "Obstructions to riding", and "Bicycle detection box"
    pickerCategories = @[@"Note this asset", @"Water fountains", @"Secret passage", @"Public restrooms", @"Bike Shops", @"Bike parking", @"...", @"Pavement issue", @"Traffic signal", @"Enforcement", @"Bike parking", @"Bike lane issue", @"Note this issue"];
    
    // Need to add descriptions for "Parks", "Obstructions to riding", and "Bicycle detection box"
    descriptionArray = @[@"Anything else we should map to help your fellow cyclists? Share the details.", @"Here’s a spot to fill your bottle on those hot summer days… stay hydrated, people. We need you.", @"Here's an access point under the tracks, through the park, onto a trail, or over a ravine.", @"Help us make cycling mainstream… here’s a place to refresh yourself before you re-enter the fashionable world of Atlanta.", @"Have a flat, a broken chain, or spongy brakes? Or do you need a bike to jump into this world of cycling in the first place? Here's a shop ready to help.", @"Park them here and remember to secure your bike well! Please only include racks or other objects intended for bikes.", @"Anything about this spot?", @"Here’s a spot where the road needs to be repaired (pothole, rough concrete, gravel in the road, manhole cover, sewer grate).", @"Here’s a signal that you can’t activate with your bike.", @"The bike lane is always blocked here, cars disobey \"no right on red\"… anything where the cops can help make cycling safer.", @"You need a bike rack to secure your bike here.", @"Where the bike lane ends (abruptly) or is too narrow (pesky parked cars).", @"Anything else ripe for improvement: want a sharrow, a sign, a bike lane? Share the details."];
    
    // Makes sure that the picker loads at index 6.
    // The descriptionTextView needs to have it's text set.
    [self.thePicker selectRow:6 inComponent:0 animated:NO];
    descriptionTextView.text = [descriptionArray objectAtIndex:6];
    
    // Making the picker and textView more visable.
    thePicker.layer.borderWidth = 1.0;
    thePicker.layer.cornerRadius = 5.0;
    descriptionTextView.layer.borderWidth = 1.0;
    descriptionTextView.layer.cornerRadius = 5.0;
    
    thePicker.backgroundColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor lightGrayColor];
    saveBtn.enabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component
{
    // Handle the selection
    if(row < 6 || row > 6)
    {
        saveBtn.enabled = YES;
    }
    else
    {
        saveBtn.enabled = NO;
    }
    rowNum = row;
    descriptionTextView.text = descriptionArray[row];
}

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 13;
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {

    // Runs 12 times. When row is equal to i the title is set
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
    if(row >= 0 && row < 6)
    {
        assetView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 10, assetView.frame.size.width - 50, 27)];
        titleLabel.text = [pickerCategories objectAtIndex:row];
        UIImageView *noteAsset = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noteAssetMapGlyph.png"]];
        [noteAsset setFrame:CGRectMake(0, 10, 46, 27)];
        [assetView addSubview:titleLabel];
        [assetView addSubview:noteAsset];
        index = 0;
        return assetView;
    }
    else if(row > 6)
    {
        issueView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 10, issueView.frame.size.width - 50, 27)];
        titleLabel.text = [pickerCategories objectAtIndex:row];
        UIImageView *noteIssue = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noteIssueMapGlyph.png"]];
        [noteIssue setFrame:CGRectMake(0, 10, 46, 27)];
        [issueView addSubview:titleLabel];
        [issueView addSubview:noteIssue];
        index = 1;
        return issueView;
    }
    else if(row == 6)
    {
        startView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(-140, 10, startView.frame.size.width, 27)];
        titleLabel.text = @"...";
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [startView addSubview:titleLabel];
        return startView;
    }
    
    return nil;

}


-(IBAction)cancelTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"Cancel Tapped");
}

-(IBAction)saveTapped:(id)sender
{
    
    if(rowNum>=7)
    {
        rowNum = rowNum - 7;
    }
    else if(rowNum <= 5)
    {
        rowNum = 11 - rowNum;
    }

    NSLog(@"Saved was tapped");
    if(index == 0)
    {
        NSLog(@"Note This Save button pressed");
        NSLog(@"detail");
        NSLog(@"INIT + PUSH");
        
        DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailView" bundle:nil];
        detailViewController.delegate = self.delegate;
        
        //[self presentModalViewController:detailViewController animated:YES];
        [self presentViewController:detailViewController animated:YES completion:nil];
        
//        //Note: get index of type
//        NSInteger row = [customPickerView selectedRowInComponent:0];
//        
//        NSNumber *tempType = 0;
//        
//        if(row>=7){
//            tempType = [NSNumber numberWithInt:row-7];
//        }
//        else if (row<=5){
//            tempType = [NSNumber numberWithInt:11-row];
//        }
//        
//        NSLog(@"tempType: %d", [tempType intValue]);
        
        
        NSNumber *tempNum = [NSNumber numberWithInt:rowNum];

        [delegate didPickNoteType:tempNum];
        
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"EST"]];

    }
    if(index == 1)
    {
        NSLog(@"Issue Save button pressed");
        NSLog(@"detail");
        NSLog(@"INIT + PUSH");
        
        DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailView" bundle:nil];
        detailViewController.delegate = self.delegate;
        
        //[self presentModalViewController:detailViewController animated:YES];
        [self presentViewController:detailViewController animated:YES completion:nil];
        //Note: get index of picker
        //NSInteger row = [customPickerView selectedRowInComponent:0];
        
        pickedNotedType = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickedNotedType"];
        
        [[NSUserDefaults standardUserDefaults] setInteger:rowNum forKey: @"pickedNotedType"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSNumber *tempNum = [NSNumber numberWithInt:rowNum];
        
        [delegate didPickNoteType:tempNum];
        

        
        pickedNotedType = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickedNotedType"];
        
        NSLog(@"pickedNotedType is %d", pickedNotedType);
    }
}

@end
