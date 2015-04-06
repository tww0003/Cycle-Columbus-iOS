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

#import <MapKit/MapKit.h>


@class LoadingView;
@class NoteViewController;
@class Note;
@class NoteManager;

@interface SavedNotesViewController : UITableViewController
    <UINavigationControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate>
{
    NSMutableArray *notes;
    NoteManager *noteManager;
    NSManagedObjectContext *managedObjectContext;
    LoadingView *loading;
    NSInteger pickerCategory;
    Note * selectedNote;
    
    //int shouldNoteDelete;
}
@property (nonatomic, weak) NSString *shouldNoteDelete;
@property (nonatomic, strong) NSMutableArray *notes;
@property (nonatomic, strong) NoteManager *noteManager;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) Note *selectedNote;

- (void)initNoteManager:(NoteManager*)manager;

- (id)initWithManagedObjectContext:(NSManagedObjectContext*)context;
- (id)initWithNoteManager:(NoteManager*)manager;

- (void)displayUploadedNote;
-(void)deleteUselessNote;


@end
