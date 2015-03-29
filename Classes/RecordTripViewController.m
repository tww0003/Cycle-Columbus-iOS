/** Cycle Atlanta, Copyright 2012, 2013 Georgia Institute of Technology
 *                                    Atlanta, GA. USA
 *
 *   @author Christopher Le Dantec <ledantec@gatech.edu>
 *   @author Anhong Guo <guoanhong@gatech.edu>
 *
 *   Updated/Modified for Atlanta's app deployment. Based on the
 *   CycleTracks codebase for SFCTA.
 *
 ** CycleTracks, Copyright 2009,2010 San Francisco County Transportation Authority
 *                                    San Francisco, CA, USA
 *
 *   @author Matt Paul <mattpaul@mopimp.com>
 *
 *   This file is part of CycleTracks.
 *
 *   CycleTracks is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   CycleTracks is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with CycleTracks.  If not, see <http://www.gnu.org/licenses/>.
 */

//
//  RecordTripViewController.m
//  CycleTracks
//
//  Copyright 2009-2010 SFCTA. All rights reserved.
//  Written by Matt Paul <mattpaul@mopimp.com> on 8/10/09.
//	For more information on the project, 
//	e-mail Billy Charlton at the SFCTA <billy.charlton@sfcta.org>


#import "constants.h"
#import "MapViewController.h"
#import "NoteViewController.h"
#import "PersonalInfoViewController.h"
#import "PickerViewController.h"
#import "RecordTripViewController.h"
#import "ReminderManager.h"
#import "TripManager.h"
#import "NoteManager.h"
#import "Trip.h"
#import "User.h"

@implementation RecordTripViewController

@synthesize tripManager;// reminderManager;
@synthesize noteManager;
@synthesize infoButton, saveButton, startButton, noteButton, parentView;
@synthesize timer, timeCounter, distCounter;
@synthesize recording, shouldUpdateCounter, userInfoSaved;
@synthesize appDelegate;
@synthesize saveActionSheet;
@synthesize locationManager;

#pragma mark CLLocationManagerDelegate methods


- (CLLocationManager *)getLocationManager {
	appDelegate = [[UIApplication sharedApplication] delegate];
    if (appDelegate.locationManager != nil) {
        return appDelegate.locationManager;
    }
	
    appDelegate.locationManager = [[CLLocationManager alloc] init];
    appDelegate.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    //locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    appDelegate.locationManager.delegate = self;
    
    return appDelegate.locationManager;
}


- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
	CLLocationDistance deltaDistance = [newLocation distanceFromLocation:oldLocation];
    
    if (!myLocation) {
        myLocation = newLocation;
    }
    else if ([myLocation distanceFromLocation:newLocation]) {
        myLocation = newLocation;
    }
    
	if ( !didUpdateUserLocation )
	{
		NSLog(@"zooming to current user location");
		MKCoordinateRegion region = { newLocation.coordinate, { 0.0078, 0.0068 } };
		[mapView setRegion:region animated:YES];

		didUpdateUserLocation = YES;
	}
	
	// only update map if deltaDistance is at least some epsilon 
	else if ( deltaDistance > 1.0 )
	{
		//NSLog(@"center map to current user location");
		[mapView setCenterCoordinate:newLocation.coordinate animated:YES];
	}

	if ( recording )
	{
		// add to CoreData store
		CLLocationDistance distance = [tripManager addCoord:newLocation];
		self.distCounter.text = [NSString stringWithFormat:@"%.1f mi", distance / 1609.344];
	}
	
	// 	double mph = ( [trip.distance doubleValue] / 1609.344 ) / ( [trip.duration doubleValue] / 3600. );
	if ( newLocation.speed >= 0. )
		speedCounter.text = [NSString stringWithFormat:@"%.1f mph", newLocation.speed * 3600 / 1609.344];
	else
		speedCounter.text = @"0.0 mph";
}


- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
	NSLog(@"locationManager didFailWithError: %@", error );
}


#pragma mark MKMapViewDelegate methods

- (void)initTripManager:(TripManager*)manager
{
	manager.dirty			= YES;
	self.tripManager		= manager;
    manager.parent          = self;
}


- (void)initNoteManager:(NoteManager*)manager
{
	self.noteManager = manager;
    manager.parent = self;
}


- (BOOL)hasUserInfoBeenSaved
{
	BOOL					response = NO;
	NSManagedObjectContext	*context = tripManager.managedObjectContext;
	NSFetchRequest			*request = [[NSFetchRequest alloc] init];
	NSEntityDescription		*entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
	[request setEntity:entity];
	
	NSError *error;
	NSInteger count = [context countForFetchRequest:request error:&error];
	//NSLog(@"saved user count  = %d", count);
	if ( count )
	{	
		NSArray *fetchResults = [context executeFetchRequest:request error:&error];
		if ( fetchResults != nil )
		{
			User *user = (User*)[fetchResults objectAtIndex:0];
			if (user			!= nil &&
				(user.age		!= nil ||
				 user.gender	!= nil ||
				 user.email		!= nil ||
				 user.homeZIP	!= nil ||
				 user.workZIP	!= nil ||
				 user.schoolZIP	!= nil ||
				 ([user.cyclingFreq intValue] < 4 )))
			{
				NSLog(@"found saved user info");
				self.userInfoSaved = YES;
				response = YES;
			}
			else
				NSLog(@"no saved user info");
		}
		else
		{
			// Handle the error.
			NSLog(@"no saved user");
			if ( error != nil )
				NSLog(@"PersonalInfo viewDidLoad fetch error %@, %@", error, [error localizedDescription]);
		}
	}
	else
		NSLog(@"no saved user");
	
	return response;
}


- (void)hasRecordingBeenInterrupted
{
	if ( [tripManager countUnSavedTrips] )
	{        
        [self resetRecordingInProgress];
	}
	else
		NSLog(@"no unsaved trips found");
}


- (void)infoAction:(id)sender
{
	if ( !recording )
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString: kInfoURL]];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc] init];
    if(IS_OS_8_OR_LATER)
    {
        [self.locationManager requestAlwaysAuthorization];
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    NSLog(@"RecordTripViewController viewDidLoad");
    NSLog(@"Bundle ID: %@", [[NSBundle mainBundle] bundleIdentifier]);
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
	
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    self.navigationController.navigationBarHidden = YES;
	
	// init map region to Atlanta
	//MKCoordinateRegion region = { { 33.749038, -84.388068 }, { 0.0078, 0.0068 } };
    MKCoordinateRegion region = {{ 32.4922, -84.9403 }, {0.0078, 0.0068 } };

	[mapView setRegion:region animated:NO];
	
	// setup info button used when showing recorded trips
	infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
	infoButton.showsTouchWhenHighlighted = YES;
	
	// Set up the buttons.
	[self.view addSubview:[self createStartButton]];
    [self.view addSubview:[self createNoteButton]];
	
    appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.isRecording = NO;
	self.recording = NO;
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey: @"recording"];
    [[NSUserDefaults standardUserDefaults] synchronize];
	self.shouldUpdateCounter = NO;
	
	// Start the location manager.
	[[self getLocationManager] startUpdatingLocation];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    // setup the noteManager
    [self initNoteManager:[[NoteManager alloc] initWithManagedObjectContext:context]];
    
	// check if any user data has already been saved and pre-select personal info cell accordingly
	if ( [self hasUserInfoBeenSaved] )
		[self setSaved:YES];
	
	// check for any unsaved trips / interrupted recordings
	[self hasRecordingBeenInterrupted];
    
	NSLog(@"save");

}

- (void)viewWillAppear:(BOOL)animated
{    	    
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


- (UIButton *)createNoteButton
{
    UIImage *buttonImage = [[UIImage imageNamed:@"whiteButton.png"]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"whiteButtonHighlight.png"]
                                     resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    
    [noteButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [noteButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [noteButton setTitleColor:[[UIColor alloc] initWithRed:185.0 / 255 green:91.0 / 255 blue:47.0 / 255 alpha:1.0 ] forState:UIControlStateHighlighted];
    
    noteButton.backgroundColor = [UIColor clearColor];
    noteButton.enabled = YES;
    
    [noteButton setTitle:@"Note this..." forState:UIControlStateNormal];

//    noteButton.titleLabel.font = [UIFont boldSystemFontOfSize: 24];
    [noteButton addTarget:self action:@selector(notethis:) forControlEvents:UIControlEventTouchUpInside];
    
	return noteButton;
    
}


// instantiate start button
- (UIButton *)createStartButton
{
    UIImage *buttonImage = [[UIImage imageNamed:@"greenButton.png"]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"greenButtonHighlight.png"]
                                     resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    
    [startButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [startButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    
    startButton.backgroundColor = [UIColor clearColor];
    startButton.enabled = YES;
    
    [startButton setTitle:@"Start" forState:UIControlStateNormal];
    [startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    startButton.titleLabel.font = [UIFont boldSystemFontOfSize: 18];
    startButton.titleLabel.shadowOffset = CGSizeMake (0, 0);
    startButton.titleLabel.textColor = [UIColor whiteColor];
    [startButton addTarget:self action:@selector(start:) forControlEvents:UIControlEventTouchUpInside];
    
	return startButton;
}


- (void)displayUploadedTripMap
{
    Trip *trip = tripManager.trip;
    [self resetRecordingInProgress];
    
    // load map view of saved trip
    MapViewController *mvc = [[MapViewController alloc] initWithTrip:trip];
    [[self navigationController] pushViewController:mvc animated:YES];
    NSLog(@"displayUploadedTripMap");
}


- (void)displayUploadedNote
{
    Note *note = noteManager.note;
    
    // load map view of note
    NoteViewController *mvc = [[NoteViewController alloc] initWithNote:note];
    [[self navigationController] pushViewController:mvc animated:YES];
    NSLog(@"displayUploadedNote");
}


- (void)resetTimer
{	
	// invalidate timer
	if ( timer )
	{
		[timer invalidate];
		//[timer release];
		timer = nil;
	}
}


- (void)resetRecordingInProgress
{
	// reset button states
    appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.isRecording = NO;
	recording = NO;
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey: @"recording"];
    [[NSUserDefaults standardUserDefaults] synchronize];
	startButton.enabled = YES;
    UIImage *buttonImage = [[UIImage imageNamed:@"greenButton.png"]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"greenButtonHighlight.png"]
                                     resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    
    [startButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [startButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [startButton setTitle:@"Start" forState:UIControlStateNormal];
	
	// reset trip, reminder managers
	NSManagedObjectContext *context = tripManager.managedObjectContext;
	[self initTripManager:[[TripManager alloc] initWithManagedObjectContext:context]];
	tripManager.dirty = YES;
    
	[self resetCounter];
	[self resetTimer];
}

- (void)resetRecordingInProgressDelete
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Trip" inManagedObjectContext:tripManager.managedObjectContext];
	[request setEntity:entity];
	
	// configure sort order
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"start" ascending:NO];
    NSSortDescriptor *sortDescriptorSaved = [[NSSortDescriptor alloc] initWithKey:@"saved" ascending:NO];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, sortDescriptorSaved, nil];
	[request setSortDescriptors:sortDescriptors];
	
	NSError *error;
	NSInteger count = [tripManager.managedObjectContext countForFetchRequest:request error:&error];
	NSLog(@"count = %d", count);
	
	NSMutableArray *mutableFetchResults = [[tripManager.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
    if([mutableFetchResults count] > 0)
       {
           NSManagedObject *tripToDelete = [mutableFetchResults objectAtIndex:0];
           
           if (tripManager.trip!= nil && tripManager.trip.saved == nil) {
               [noteManager.managedObjectContext deleteObject:tripToDelete];
           }
           
           
           if (![tripManager.managedObjectContext save:&error]) {
               // Handle the error.
               NSLog(@"Unresolved error %@", [error localizedDescription]);
           }

       }
    //
    else{
        NSLog(@"There is nothing in NSManagedObject *tripToDelete = [mutableFetchResults objectAtIndex:0];");
    }
    // reset button states
    appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.isRecording = NO;
    recording = NO;
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey: @"recording"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    startButton.enabled = YES;
    UIImage *buttonImage = [[UIImage imageNamed:@"greenButton.png"]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"greenButtonHighlight.png"]
                                     resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    
    [startButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [startButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [startButton setTitle:@"Start" forState:UIControlStateNormal];
    
    // reset trip, reminder managers
    NSManagedObjectContext *context = tripManager.managedObjectContext;
    [self initTripManager:[[TripManager alloc] initWithManagedObjectContext:context]];
    tripManager.dirty = YES;
    
    [self resetCounter];
    [self resetTimer];

    
}


#pragma mark UIActionSheet delegate methods


// NOTE: implement didDismissWithButtonIndex to process after sheet has been dismissed
//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	NSLog(@"actionSheet clickedButtonAtIndex %d", buttonIndex);
	switch ( buttonIndex )
	{			
       case 0:
       {
           NSLog(@"Discard!!!!");
           [self resetRecordingInProgressDelete];
           //discard that trip
           break;
       }
        case 1:{
            [self save];
            break;
        }
		default:{
			NSLog(@"Cancel");
			// re-enable counter updates
			shouldUpdateCounter = YES;
			break;
        }
	}
}


// called if the system cancels the action sheet (e.g. homescreen button has been pressed)
- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
	NSLog(@"actionSheetCancel");
}


#pragma mark UIAlertViewDelegate methods


// NOTE: method called upon closing save error / success alert
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	switch (alertView.tag) {
		case 101:
		{
			NSLog(@"recording interrupted didDismissWithButtonIndex: %d", buttonIndex);
			switch (buttonIndex) {
				case 0:
					// new trip => do nothing
					break;
				case 1:
				default:
					// continue => load most recent unsaved trip
					[tripManager loadMostRecetUnSavedTrip];
					
					// update UI to reflect trip once loading has completed
					[self setCounterTimeSince:tripManager.trip.start
									 distance:[tripManager getDistanceEstimate]];

					startButton.enabled = YES;

                    [startButton setTitle:@"Continue" forState:UIControlStateNormal];
					break;
			}
		}
			break;
		default:
		{
			NSLog(@"saving didDismissWithButtonIndex: %d", buttonIndex);
			
			// keep a pointer to our trip to pass to map view below
			Trip *trip = tripManager.trip;
			[self resetRecordingInProgress];
			
			// load map view of saved trip
			MapViewController *mvc = [[MapViewController alloc] initWithTrip:trip];
			[[self navigationController] pushViewController:mvc animated:YES];
		}
			break;
	}
}

//TODO memory leak here... autorelease instead?
- (NSDictionary *)newTripTimerUserInfo
{
    return [NSDictionary dictionaryWithObjectsAndKeys:[NSDate date], @"StartDate",
			tripManager, @"TripManager", nil ];
}


// handle start button action
- (IBAction)start:(UIButton *)sender
{
    
    if(recording == NO)
    {
        NSLog(@"start");
        
        // start the timer if needed
        if ( timer == nil )
        {
			[self resetCounter];
			timer = [NSTimer scheduledTimerWithTimeInterval:kCounterTimeInterval
													 target:self selector:@selector(updateCounter:)
												   userInfo:[self newTripTimerUserInfo] repeats:YES];
        }
        
        UIImage *buttonImage = [[UIImage imageNamed:@"blueButton.png"]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
        UIImage *buttonImageHighlight = [[UIImage imageNamed:@"blueButtonHighlight.png"]
                                         resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
        [startButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [startButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
        [startButton setTitle:@"Save" forState:UIControlStateNormal];

        // set recording flag so future location updates will be added as coords
        appDelegate = [[UIApplication sharedApplication] delegate];
        appDelegate.isRecording = YES;
        recording = YES;
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey: @"recording"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // set flag to update counter
        shouldUpdateCounter = YES;
    }
    // do the saving
    else
    {
        NSLog(@"User Press Save Button");
        saveActionSheet = [[UIActionSheet alloc]
                           initWithTitle:@""
                           delegate:self
                           cancelButtonTitle:@"Continue"
                           destructiveButtonTitle:@"Discard"
                           otherButtonTitles:@"Save",nil];
        [saveActionSheet showInView:[UIApplication sharedApplication].keyWindow];
    }
	
}
- (void)save
{
	[[NSUserDefaults standardUserDefaults] setInteger:0 forKey: @"pickerCategory"];
    [[NSUserDefaults standardUserDefaults] synchronize];
	// go directly to TripPurpose, user can cancel from there
	if ( YES )
	{
		// Trip Purpose
//		NSLog(@"INIT + PUSH TripPurposePickerView");
//		PickerViewController *tripPurposePickerView = [[PickerViewController alloc]
//													  //initWithPurpose:[tripManager getPurposeIndex]];
//													  initWithNibName:@"TripPurposePicker" bundle:nil];
//		[tripPurposePickerView setDelegate:self];
//		//[self.navigationController presentModalViewController:tripPurposePickerView animated:YES];
//        [self.navigationController pushViewController:tripPurposePickerView animated:YES];
//        //[self.navigationController dismissViewControllerAnimated:YES completion:nil];
//        
        tripPurpVC = [[NewTripPurposeViewController alloc] init];
        [tripPurpVC setDelegate:self];
        [self.navigationController pushViewController:tripPurpVC animated:YES];

	}
	
	// prompt to confirm first
	else
	{
		// pause updating the counter
		shouldUpdateCounter = NO;
		
		// construct purpose confirmation string
		NSString *purpose = nil;
		if ( tripManager != nil )
			purpose = [self getPurposeString:[tripManager getPurposeIndex]];
		
		NSString *confirm = [NSString stringWithFormat:@"Stop recording & save this trip?"];
		
		// present action sheet
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:confirm
																 delegate:self
														cancelButtonTitle:@"Cancel"
												   destructiveButtonTitle:nil
														otherButtonTitles:@"Save", nil];
		
		actionSheet.actionSheetStyle		= UIActionSheetStyleBlackTranslucent;
		UIViewController *pvc = self.parentViewController;
		UITabBarController *tbc = (UITabBarController *)pvc.parentViewController;
		
		[actionSheet showFromTabBar:tbc.tabBar];
	}
    
}


-(IBAction)notethis:(id)sender{
    [[NSUserDefaults standardUserDefaults] setInteger:3 forKey: @"pickerCategory"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"Note This");
    
    if (myLocation){
        [noteManager addLocation:myLocation];
    }
	
	// go directly to TripPurpose, user can cancel from there
	if ( YES )
	{
		// Trip Purpose
		NSLog(@"INIT + PUSH");
        
        
//		PickerViewController *notePickerView = [[PickerViewController alloc]
//                                                       //initWithPurpose:[tripManager getPurposeIndex]];
//                                                       initWithNibName:@"TripPurposePicker" bundle:nil];
//		[notePickerView setDelegate:self];
//		//[[self navigationController] pushViewController:pickerViewController animated:YES];
//		//[self.navigationController presentModalViewController:notePickerView animated:YES];
//        [self.navigationController presentViewController:notePickerView animated:YES completion:nil];
        
        pickerVC = [[NewPickerViewController alloc] init];
        [pickerVC setDelegate:self];
        [self.navigationController presentViewController:pickerVC animated:YES completion:nil];
        
        //add location information
        
	}
	
	// prompt to confirm first
    /*
	else
	{
		// pause updating the counter
		shouldUpdateCounter = NO;
		
		// construct purpose confirmation string
		NSString *purpose = nil;
		if ( tripManager != nil )
			purpose = [self getPurposeString:[tripManager getPurposeIndex]];
		
		NSString *confirm = [NSString stringWithFormat:@"Stop recording & save this trip?"];
		
		// present action sheet
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:confirm
																 delegate:self
														cancelButtonTitle:@"Cancel"
												   destructiveButtonTitle:nil
														otherButtonTitles:@"Save", nil];
		
		actionSheet.actionSheetStyle		= UIActionSheetStyleBlackTranslucent;
		UIViewController *pvc = self.parentViewController;
		UITabBarController *tbc = (UITabBarController *)pvc.parentViewController;
		
		[actionSheet showFromTabBar:tbc.tabBar];
	}
     */
}


- (void)resetCounter
{
	if ( timeCounter != nil )
		timeCounter.text = @"00:00:00";
	
	if ( distCounter != nil )
		distCounter.text = @"0 mi";
}


- (void)setCounterTimeSince:(NSDate *)startDate distance:(CLLocationDistance)distance
{
	if ( timeCounter != nil )
	{
		NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:startDate];
		
		static NSDateFormatter *inputFormatter = nil;
		if ( inputFormatter == nil )
			inputFormatter = [[NSDateFormatter alloc] init];
		
		[inputFormatter setDateFormat:@"HH:mm:ss"];
		NSDate *fauxDate = [inputFormatter dateFromString:@"00:00:00"];
		[inputFormatter setDateFormat:@"HH:mm:ss"];
		NSDate *outputDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:fauxDate];
		
		timeCounter.text = [inputFormatter stringFromDate:outputDate];
	}
	
	if ( distCounter != nil )
		distCounter.text = [NSString stringWithFormat:@"%.1f mi", distance / 1609.344];
;
}


// handle start button action
- (void)updateCounter:(NSTimer *)theTimer
{
	//NSLog(@"updateCounter");
	if ( shouldUpdateCounter )
	{
		NSDate *startDate = [[theTimer userInfo] objectForKey:@"StartDate"];
		NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:startDate];

		static NSDateFormatter *inputFormatter = nil;
		if ( inputFormatter == nil )
			inputFormatter = [[NSDateFormatter alloc] init];
		
		[inputFormatter setDateFormat:@"HH:mm:ss"];
		NSDate *fauxDate = [inputFormatter dateFromString:@"00:00:00"];
		[inputFormatter setDateFormat:@"HH:mm:ss"];
		NSDate *outputDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:fauxDate];
		
		//NSLog(@"Timer started on %@", startDate);
		//NSLog(@"Timer started %f seconds ago", interval);
		//NSLog(@"elapsed time: %@", [inputFormatter stringFromDate:outputDate] );
		
		//self.timeCounter.text = [NSString stringWithFormat:@"%.1f sec", interval];
		self.timeCounter.text = [inputFormatter stringFromDate:outputDate];
	}
}




- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


- (void)keyboardWillShow:(NSNotification *)aNotification
{
	NSLog(@"keyboardWillShow");
}


- (void)keyboardWillHide:(NSNotification *)aNotification
{
	NSLog(@"keyboardWillHide");
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


- (NSString *)updatePurposeWithString:(NSString *)purpose
{	
	// only enable start button if we don't already have a pending trip
	if ( timer == nil )
		startButton.enabled = YES;
	startButton.hidden = NO;
	
	return purpose;
}


- (NSString *)updatePurposeWithIndex:(unsigned int)index
{
	return [self updatePurposeWithString:[tripManager getPurposeString:index]];
}


#pragma mark UINavigationController


- (void)navigationController:(UINavigationController *)navigationController 
	   willShowViewController:(UIViewController *)viewController 
					animated:(BOOL)animated
{
	if ( viewController == self )
	{
		//NSLog(@"willShowViewController:self");
		self.title = @"Record New Trip";
	}
	else
	{
		//NSLog(@"willShowViewController:else");
		self.title = @"Back";
		self.tabBarItem.title = @"Record New Trip"; // important to maintain the same tab item title
	}
}


#pragma mark UITabBarControllerDelegate


- (BOOL)tabBarController:(UITabBarController *)tabBarController 
shouldSelectViewController:(UIViewController *)viewController
{
		return YES;		
}


#pragma mark PersonalInfoDelegate methods


- (void)setSaved:(BOOL)value
{
	NSLog(@"setSaved");
	// no-op

}


#pragma mark TripPurposeDelegate methods


- (NSString *)setPurpose:(unsigned int)index
{
	NSString *purpose = [tripManager setPurpose:index];
	NSLog(@"setPurpose: %@", purpose);
	
	return [self updatePurposeWithString:purpose];
}


- (NSString *)getPurposeString:(unsigned int)index
{
	return [tripManager getPurposeString:index];
}


- (void)didCancelPurpose
{
	//[self.navigationController dismissModalViewControllerAnimated:YES];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];

    appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.isRecording = YES;
	recording = YES;
    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey: @"recording"];
    [[NSUserDefaults standardUserDefaults] synchronize];
	shouldUpdateCounter = YES;
}

- (void)didCancelNote
{
	//[self.navigationController dismissModalViewControllerAnimated:YES];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    appDelegate = [[UIApplication sharedApplication] delegate];
}


- (void)didCancelNoteDelete
{
	//[self.navigationController dismissModalViewControllerAnimated:YES];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    appDelegate = [[UIApplication sharedApplication] delegate];
    
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:noteManager.managedObjectContext];
	[request setEntity:entity];
    
    [request setReturnsDistinctResults:YES];
    [request setPropertiesToFetch:[NSArray arrayWithObjects:@"note_type",@"recorded",nil]];
    
	// configure sort order
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"recorded" ascending:NO];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors:sortDescriptors];
	
	NSError *error;
	NSInteger count = [noteManager.managedObjectContext countForFetchRequest:request error:&error];
	NSLog(@"count = %d", count);
	
	NSMutableArray *mutableFetchResults = [[noteManager.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
//warning causes crash
    
    NSManagedObject *noteToDelete = [mutableFetchResults objectAtIndex:0];
    [noteManager.managedObjectContext deleteObject:noteToDelete];
    
    if (![noteManager.managedObjectContext save:&error]) {
        // Handle the error.
        NSLog(@"Unresolved error %@", [error localizedDescription]);
    }
    

}


- (void)didPickPurpose:(unsigned int)index
{
	// update UI
    appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.isRecording = NO;
	recording = NO;
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey: @"recording"];
    [[NSUserDefaults standardUserDefaults] synchronize];
	startButton.enabled = YES;
	[self resetTimer];
	
	[tripManager setPurpose:index];
    //do something here: may change to be the save as a separate view. Not prompt.
}

- (void)didEnterTripDetails:(NSString *)details{
    [tripManager saveNotes:details];
    NSLog(@"Trip Added details: %@",details);
}

- (void)saveTrip{
    [tripManager saveTrip];
    NSLog(@"Save trip");
}

- (void)didPickNoteType:(NSNumber *)index
{	
	[noteManager.note setNote_type:index];
    NSLog(@"Added note type: %d", [noteManager.note.note_type intValue]);
    //do something here: may change to be the save as a separate view. Not prompt.
}

- (void)didEnterNoteDetails:(NSString *)details{
    [noteManager.note setDetails:details];
    NSLog(@"Note Added details: %@", noteManager.note.details);
}

- (void)didSaveImage:(NSData *)imgData{
    [noteManager.note setImage_data:imgData];
    NSLog(@"Added image, Size of Image(bytes):%d", [imgData length]);
}

- (void)getTripThumbnail:(NSData *)imgData{
    [tripManager.trip setThumbnail:imgData];
    NSLog(@"Trip Thumbnail, Size of Image(bytes):%d", [imgData length]);
}

- (void)getNoteThumbnail:(NSData *)imgData{
    [noteManager.note setThumbnail:imgData];
    NSLog(@"Note Thumbnail, Size of Image(bytes):%d", [imgData length]);
}

- (void)saveNote{
    [noteManager saveNote];
    NSLog(@"Save note");
}

#pragma mark RecordingInProgressDelegate method

- (Trip *)getRecordingInProgress
{
	if ( recording )
		return tripManager.trip;
	else
		return nil;
}


- (void)dealloc {
    
    appDelegate.locationManager = nil;
    self.timer = nil;
    self.recording = nil;
    self.shouldUpdateCounter = nil;
    self.userInfoSaved = nil;
    
}

@end