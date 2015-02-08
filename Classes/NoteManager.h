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
//  TripManager.h
//  CycleTracks
//
//  Copyright 2009-2010 SFCTA. All rights reserved.
//  Written by Matt Paul <mattpaul@mopimp.com> on 9/22/09.
//	For more information on the project,
//	e-mail Billy Charlton at the SFCTA <billy.charlton@sfcta.org>


#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import "ActivityIndicatorDelegate.h"
#import "LoadingView.h"
#import "Note.h"
#import "SavedNotesViewController.h"

@class Note;


@interface NoteManager : NSObject 
{
	Note *note;
    NSManagedObjectContext *managedObjectContext;
	NSMutableData *receivedDataNoted;
    NSString *deviceUniqueIdHash1;
    SavedNotesViewController *savedNotes;
}

@property (nonatomic, strong) NSString *deviceUniqueIdHash1;
@property (nonatomic, strong) id <ActivityIndicatorDelegate> activityDelegate;
@property (nonatomic, strong) id <UIAlertViewDelegate> alertDelegate;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) LoadingView *uploadingView;
@property (nonatomic, strong) UIViewController *parent;
@property (assign) BOOL dirty;
@property (nonatomic, strong) Note *note;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSMutableData *receivedDataNoted;

- (id)initWithManagedObjectContext:(NSManagedObjectContext*)context;
- (void)saveNote;
- (void)saveNote:(Note*)note;
- (void)createNote;
- (void)addLocation:(CLLocation*)locationNow;
- (id)initWithNote:(Note*)note;
- (BOOL)loadNote:(Note *)note;

@end


