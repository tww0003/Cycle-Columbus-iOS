//
//  LeaderboardViewController.h
//  Cycle Atlanta
//
//  Created by Nathaniel Thomas on 4/10/15.
//
//

#import <UIKit/UIKit.h>

@interface LeaderboardViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
{
    NSDictionary *jsonLeaderboardData;
}

@property(nonatomic, weak) IBOutlet UITableView *leaderboardTableView;

@end
