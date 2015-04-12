//
//  LeaderboardViewController.h
//  Fountain City Cycling
//
//  Created by Tyler Williamson on 4/10/15.
//
//

#import <UIKit/UIKit.h>

@interface LeaderboardViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
{
    NSDictionary *jsonLeaderboardData;
}

@property(nonatomic, weak) IBOutlet UITableView *leaderboardTableView;

@end
