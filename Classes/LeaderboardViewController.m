//
//  LeaderboardViewController.m
//  Cycle Atlanta
//
//  Created by Nathaniel Thomas on 4/10/15.
//
//

#import "LeaderboardViewController.h"

@interface LeaderboardViewController ()

@end

@implementation LeaderboardViewController
@synthesize leaderboardTableView;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    jsonLeaderboardData = [self downloadLeaderboard];
    
    NSLog(@"%@", [jsonLeaderboardData description]);
    
    UIBarButtonItem *flipButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Back"
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                   action:@selector(back)];
    self.navigationItem.leftBarButtonItem = flipButton;
    UIBarButtonItem *whatsMyUserId = [[UIBarButtonItem alloc]
                                   initWithTitle:@"What's my User ID?"
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                   action:@selector(userID)];
    self.navigationItem.rightBarButtonItem = whatsMyUserId;
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;



}

-(void)back
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


// Displaying the userID
-(void)userID
{
    NSString *userIdNum;
    BOOL isItThere = false;
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"deviceIDbased"])
    {
        for(int i = 0; i < [[jsonLeaderboardData objectForKey:@"leaders"] count]; i++)
        {
            if([[[jsonLeaderboardData objectForKey:@"leaders"] objectAtIndex:i] objectForKey:@"device"] != [NSNull null])
            {
                userIdNum = [[[jsonLeaderboardData objectForKey:@"leaders"] objectAtIndex:i] objectForKey:@"device"];
                if([userIdNum isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"deviceIDbased"]])
                {
                    NSString *theRealDeal = [[[jsonLeaderboardData objectForKey:@"leaders"] objectAtIndex:i] objectForKey:@"user_id"];
                    UIAlertView *userIdAlert = [[UIAlertView alloc] initWithTitle:@"User ID" message:[NSString stringWithFormat:@"Your User ID is %@", theRealDeal] delegate:self cancelButtonTitle:@"Thanks!" otherButtonTitles: nil];
                    [userIdAlert show];
                    isItThere = true;
                }
            }
        }
        if(isItThere == false)
        {
            UIAlertView *userIdAlert = [[UIAlertView alloc] initWithTitle:@"User ID" message:@"User ID not available" delegate:self cancelButtonTitle:@"Sorry :/" otherButtonTitles: nil];
            [userIdAlert show];
        }

    }
    else
    {
        UIAlertView *userIdAlert = [[UIAlertView alloc] initWithTitle:@"User ID" message:@"User ID not available" delegate:self cancelButtonTitle:@"Sorry :/" otherButtonTitles: nil];
        [userIdAlert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        //delete it
    }
}


-(NSDictionary *)downloadLeaderboard
{
    // Grabbing the json data
    NSString *link =  [NSString stringWithFormat:@"http://fountaincitycycling.org/leaderboard_request"];
    NSString *encdLink = [link stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:encdLink];
    NSData *response = [NSData dataWithContentsOfURL:url];
    NSError *error;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:response options: NSJSONReadingMutableContainers error: &error];

    
    return  jsonDict;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[jsonLeaderboardData objectForKey:@"leaders"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"jsonLeaderBoard";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.numberOfLines = 2;

    }

    NSString *userNameAndScore = [NSString stringWithFormat:@"User ID: %@\n Score: %@",[[[jsonLeaderboardData objectForKey:@"leaders"] objectAtIndex:indexPath.row] objectForKey:@"user_id"], [[[jsonLeaderboardData objectForKey:@"leaders"] objectAtIndex:indexPath.row] objectForKey:@"score"]];
    cell.textLabel.text = userNameAndScore;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Change the selected background view of the cell.
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
