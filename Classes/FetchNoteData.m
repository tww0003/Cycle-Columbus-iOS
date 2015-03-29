/** Cycle Atlanta, Copyright 2012, 2013 Georgia Institute of Technology
 *                                    Atlanta, GA. USA
 *
 *   @author Christopher Le Dantec <ledantec@gatech.edu>
 *   @author Anhong Guo <guoanhong@gatech.edu>
 *
 *   Cycle Atlanta is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   Cycle Atlanta is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with Cycle Atlanta.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "FetchUser.h"
#import "FetchNoteData.h"
#import "constants.h"
#import "CycleAtlantaAppDelegate.h"
#import "Coord.h"
#import "Note.h"

@class NoteManager;

@implementation FetchNoteData

@synthesize managedObjectContext,  downloadingProgressView, downloadCount;

- (id)init{
    self.managedObjectContext = [(CycleAtlantaAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    return self;
}

- (id)initWithDataCountAndProgessView:(int) dataCount progressView:(ProgressView*) progressView{
    self.downloadingProgressView = progressView;
    self.downloadCount = dataCount;
    return [self init];
}

- (void)fetchWithNotes:(NSMutableArray*) notes
{
    UIBackgroundTaskIdentifier taskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^(void) {
        
    }];
    
    NSError *error;
    for(NSDictionary* noteDict in notes)
    {
        
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"EST"]];
        
        //Add the note
        Note * newNote = (Note *)[NSEntityDescription insertNewObjectForEntityForName:@"Note"
                                                               inManagedObjectContext:self.managedObjectContext] ;
        [newNote setNote_type:  [NSNumber numberWithInteger:[[noteDict objectForKey:@"note_type"] intValue]]];
        [newNote setRecorded:   [dateFormat dateFromString:[noteDict objectForKey:@"recorded"]]];
        [newNote setUploaded:   [dateFormat dateFromString:[noteDict objectForKey:@"recorded"]]];
        [newNote setDetails:    [noteDict objectForKey:@"details"]];
        [newNote setImage_url:  [noteDict objectForKey:@"image_url"]];
        [newNote setAltitude:   [NSNumber numberWithDouble:[[noteDict objectForKey:@"altitude"] doubleValue]]]; 
        [newNote setLatitude:   [NSNumber numberWithDouble:[[noteDict objectForKey:@"latitude"] doubleValue]]];
        [newNote setLongitude:  [NSNumber numberWithDouble:[[noteDict objectForKey:@"longitude"] doubleValue]]];
        [newNote setSpeed:      [NSNumber numberWithDouble:[[noteDict objectForKey:@"speed"] doubleValue]]];
        [newNote setHAccuracy:  [NSNumber numberWithDouble:[[noteDict objectForKey:@"hAccuracy"] doubleValue]]];
        [newNote setVAccuracy:  [NSNumber numberWithDouble:[[noteDict objectForKey:@"vAccuracy"] doubleValue]]]; 
                
        if(![newNote.image_url isEqual: @""])
        {
            NSString *url = @"http://fountaincitycycling.org/uploads/";
            url = [url stringByAppendingString:newNote.image_url];
            url = [url stringByAppendingString:@".jpg"];
            NSLog(@"Note image URL: %@",url);
                
            [newNote setImage_data:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
        }
        
        
        if (![self.managedObjectContext save:&error]) {
            // Handle the error.
            NSLog(@"NoteManager addNote error %@, %@", error, [error localizedDescription]);
        }
                
        [self.downloadingProgressView updateProgress:1.0f/[[NSNumber numberWithInt:downloadCount] floatValue] ];

    }

    
    
    if (taskId != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:taskId];
    }
}

@end
