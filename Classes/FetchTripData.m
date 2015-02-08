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
#import "FetchTripData.h"
#import "constants.h"
#import "CycleAtlantaAppDelegate.h"
#import "Coord.h"
#import "Trip.h"

#define kEpsilonAccuracy		100.0
#define kEpsilonTimeInterval	10.0
#define kEpsilonSpeed			30.0

@class TripManager;

@implementation FetchTripData

@synthesize managedObjectContext, receivedData, urlRequest, tripDict, downloadingProgressView, downloadCount, tripsToLoad;

- (id)init{
    self.managedObjectContext = [(CycleAtlantaAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    return self;
}

- (id)initWithDataCountAndProgessView:(int) dataCount progressView:(ProgressView*) progressView{
    self.downloadingProgressView = progressView;
    self.downloadCount = dataCount;
    return [self init];
}

- (void)saveTrip:(NSDictionary *)coordsDict{
    UIBackgroundTaskIdentifier taskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^(void) {
        // TODO: add better code for clean up if app times out
        // option: do nothing, user can just hit download again and the rest will come. partially download trips will not be restored
    }];
	NSError *error;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"PST"]]; 
    
    CLLocationDistance distance = 0;
    Coord *prev = nil;
    
    //Add the trip
    Trip * newTrip = (Trip *)[NSEntityDescription insertNewObjectForEntityForName:@"Trip"
                                                            inManagedObjectContext:self.managedObjectContext] ;
    [newTrip setPurpose:[tripDict objectForKey:@"purpose"]];
    [newTrip setStart:[dateFormat dateFromString:[tripDict objectForKey:@"start"]]];
    [newTrip setUploaded:[dateFormat dateFromString:[tripDict objectForKey:@"stop"]]];
    [newTrip setSaved:[NSDate date]];
    [newTrip setNotes:[tripDict objectForKey:@"notes"]];
    [newTrip setDistance:0];
    
    if (![self.managedObjectContext save:&error]) {
        // Handle the error.
        NSLog(@"TripManager addCoord error %@, %@", error, [error localizedDescription]);
    }
    //Add the coords
    Coord *newCoord = nil;
    Coord *firstCoord = nil;
    BOOL isFirstCoord = true;
    for(NSDictionary *coord in coordsDict){
        newCoord = (Coord *)[NSEntityDescription insertNewObjectForEntityForName:@"Coord" inManagedObjectContext:self.managedObjectContext];
        [newCoord setAltitude:[NSNumber numberWithDouble:[[coord objectForKey:@"altitude"] doubleValue]]];
        [newCoord setLatitude:[NSNumber numberWithDouble:[[coord objectForKey:@"latitude"] doubleValue]]];
        [newCoord setLongitude:[NSNumber numberWithDouble:[[coord objectForKey:@"longitude"] doubleValue]]];
        [newCoord setRecorded:[dateFormat dateFromString:[coord objectForKey:@"recorded"]]];
        [newCoord setSpeed:[NSNumber numberWithDouble:[[coord objectForKey:@"altitude"] doubleValue]]];
        [newCoord setHAccuracy:[NSNumber numberWithDouble:[[coord objectForKey:@"h_accuracy"] doubleValue]]];
        [newCoord setVAccuracy:[NSNumber numberWithDouble:[[coord objectForKey:@"v_accuracy"] doubleValue]]];
        
        [newTrip addCoordsObject:newCoord];
        
        if(prev){
            distance	+= [self distanceFrom:prev to:newCoord realTime:YES];
        }
        prev = newCoord;
        
        if(isFirstCoord){
            firstCoord = newCoord;
            isFirstCoord = false;
        }
    }
    // update duration
    NSTimeInterval duration = [newCoord.recorded timeIntervalSinceDate:firstCoord.recorded];
    //NSLog(@"duration = %.0fs", duration);
    [newTrip setDuration:[NSNumber numberWithDouble:duration]];
    [newTrip setDistance:[NSNumber numberWithDouble:distance]];
    
	if (![self.managedObjectContext save:&error]) {
		// Handle the error.
		NSLog(@"TripManager addCoord error %@, %@", error, [error localizedDescription]);
	}
    
    if (taskId != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:taskId];
    }
}

- (CLLocationDistance)calculateTripDistance:(Trip*)trip
{
	NSLog(@"calculateTripDistance for trip started %@ having %d coords", trip.start, [trip.coords count]);
	
	CLLocationDistance newDist = 0.;
    	
	// filter coords by hAccuracy
	NSPredicate *filterByAccuracy	= [NSPredicate predicateWithFormat:@"hAccuracy < 100.0"];
	NSArray		*filteredCoords		= [[trip.coords allObjects] filteredArrayUsingPredicate:filterByAccuracy];
	NSLog(@"count of filtered coords = %d", [filteredCoords count]);
	
	if ( [filteredCoords count] )
	{
		// sort filtered coords by recorded date
		NSSortDescriptor *sortByDate	= [[NSSortDescriptor alloc] initWithKey:@"recorded" ascending:YES];
		NSArray		*sortDescriptors	= [NSArray arrayWithObjects:sortByDate, nil];
		NSArray		*sortedCoords		= [filteredCoords sortedArrayUsingDescriptors:sortDescriptors];
		
		for (int i=1; i < [sortedCoords count]; i++)
		{
			Coord *prev	 = [sortedCoords objectAtIndex:(i - 1)];
			Coord *next	 = [sortedCoords objectAtIndex:i];
			newDist	+= [self distanceFrom:prev to:next realTime:NO];
		}
	}
	
	return newDist;
}

- (CLLocationDistance)distanceFrom:(Coord*)prev to:(Coord*)next realTime:(BOOL)realTime
{
	CLLocation *prevLoc = [[CLLocation alloc] initWithLatitude:[prev.latitude doubleValue]
                                                      longitude:[prev.longitude doubleValue]];
	CLLocation *nextLoc = [[CLLocation alloc] initWithLatitude:[next.latitude doubleValue]
                                                      longitude:[next.longitude doubleValue]];
	
	CLLocationDistance	deltaDist	= [nextLoc distanceFromLocation:prevLoc];
	NSTimeInterval		deltaTime	= [next.recorded timeIntervalSinceDate:prev.recorded];
	CLLocationDistance	newDist		= 0.;
	
	// sanity check accuracy
	if ( [prev.hAccuracy doubleValue] < kEpsilonAccuracy &&
        [next.hAccuracy doubleValue] < kEpsilonAccuracy )
	{
		// sanity check time interval
		if ( !realTime || deltaTime < kEpsilonTimeInterval )
		{
			// sanity check speed
			if ( !realTime || (deltaDist / deltaTime < kEpsilonSpeed) )
			{
				// consider distance delta as valid
				newDist += deltaDist;				
			}
		}
	}
	
	return newDist;
}

- (void)fetchWithTrips:(NSMutableArray*) trips
{
    [self.downloadingProgressView updateProgress:1.0f/[[NSNumber numberWithInt:downloadCount] floatValue] ];
    self.tripsToLoad = trips;
    NSDictionary* trip = [self.tripsToLoad lastObject];
    [self.tripsToLoad removeLastObject];
    
    if(trip)
    {
        [self fetchTripData:trip];
    }    
}


- (void)fetchTripData:(NSDictionary*) tripToLoad
{
    self.tripDict = tripToLoad;
    
    NSMutableString *postBody = [NSMutableString string];
    self.urlRequest = [[NSMutableURLRequest alloc] init] ;
    [urlRequest setURL:[NSURL URLWithString:kFetchURL] ];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"get_coords_by_trip", @"t", [self.tripDict objectForKey:@"id"], @"q", nil];
    NSString *sep = @"";
    for(NSString * key in postDict) {
        [postBody appendString:[NSString stringWithFormat:@"%@%@=%@",
                                sep,
                                key,
                                [postDict objectForKey:key]]];
        sep = @"&";
    }
    NSLog(@"POST Data: %@", postBody);
    [urlRequest setValue:[NSString stringWithFormat:@"%d", [[postBody dataUsingEncoding:NSUTF8StringEncoding] length]] forHTTPHeaderField:@"Content-Length"];
    [urlRequest setHTTPBody:[postBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
    if ( theConnection )
    {
        receivedData=[NSMutableData data];
    }
    else
    {
        // inform the user that the download could not be made
        NSLog(@"Download failed!");
    }    
}

#pragma mark NSURLConnection delegate methods


- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
//	NSLog(@"%d bytesWritten, %d totalBytesWritten, %d totalBytesExpectedToWrite",
//		  bytesWritten, totalBytesWritten, totalBytesExpectedToWrite );
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	// this method is called when the server has determined that it
    // has enough information to create the NSURLResponse
	// NSLog(@"didReceiveResponse: %@", response);
	
	NSHTTPURLResponse *httpResponse = nil;
	if ( [response isKindOfClass:[NSHTTPURLResponse class]] &&
		( httpResponse = (NSHTTPURLResponse*)response ) )
	{
		BOOL success = NO;
		NSString *title   = nil;
		NSString *message = nil;
		switch ( [httpResponse statusCode] )
		{
			case 200:
			case 201:
				success = YES;
				title	= kSuccessFetchTitle;
				message = @"Coords downloaded";//kFetchSuccess;
				break;
			case 500:
			default:
				title = @"Internal Server Error";
				message = kServerError;
		}
		
		NSLog(@"%@: %@", title, message);
        
        // DEBUG
        //NSLog(@"+++++++DEBUG didReceiveResponse %@: %@", [response URL],[(NSHTTPURLResponse*)response allHeaderFields]);
        
        if ( success )
		{
            //NSLog(@"Coord Download Success.");
            
            //[uploadingView loadingComplete:kSuccessTitle delayInterval:.7];
		} else {
            //not sure if this is needed here.
        }
	}
    // receivedData is declared as a method instance elsewhere
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // append the new data to the receivedData
	[receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // release the connection, and the data object
	
    // receivedData is declared as a method instance elsewhere
    
    [self.downloadingProgressView setErrorMessage:kFetchError];
    [self.downloadingProgressView updateProgress:1.0f/[[NSNumber numberWithInt:self.downloadCount] floatValue] ];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];

    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //NSString *dataString = [[[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding] autorelease];
    NSLog(@"+++++++DEBUG: Received %d bytes of data for trip %@", [receivedData length], [tripDict objectForKey:@"id"]);
    NSError *error;
    NSString *jsonString = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    NSDictionary *coordsDict = [NSJSONSerialization JSONObjectWithData: [jsonString dataUsingEncoding:NSUTF8StringEncoding]
                                                         options: NSJSONReadingMutableContainers
                                                           error: &error];    
    [self saveTrip:coordsDict];
    
    //Debugging received data
//    NSData *JsonDataCoords = [[NSData alloc] initWithData:[NSJSONSerialization dataWithJSONObject:JSON options:0 error:&error]];
//    NSLog(@"%@", [[[NSString alloc] initWithData:JsonDataCoords encoding:NSUTF8StringEncoding] autorelease] );

    // release the connection, and the data object
    //get the next trip from the array.
    [self fetchWithTrips:self.tripsToLoad];
}

@end
