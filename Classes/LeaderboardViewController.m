//
//  LeaderboardViewController.m
//  Fountain City Cycling
//
//  Created by Tyler Williamson on 4/10/15.
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
    NSString *message = @"By clicking “I Agree” below you are agreeing to the following rules and terms of use.\n\n1.        I agree to provide a username and email which will be used to indentify me in a leaderboard. My email will remain anonymous but my username, score, and distance traveled may be publicly displayed in a leaderboard. No other indentifying information or data collected about me will be publicly displayed.\n\n2.        I agree to receive emails from the Columbus-Phenix City MPO or Planning Department should I need to be contacted. In the event that I am a contest winner, I will be contacted by the email provided.\n\n3.        The Columbus-Phenix City MPO reserves the right to disqualify and/or remove users from the app and data collection if the app is not used as it is intended.\n\n4.        To use the app, users must be 16 years or older, in accordance with Georgia law regarding riding on roadways.\n\n5.        The Columbus-Phenix City MPO reserves the right to determine eligible and ineligible trip distances and mileage for contest purposes.\n\nIneligible distances are described below:\n\na.        Trips with speeds below 3mph for 5 consecutive minutes\n\nb.        Trips with speeds above 30 mph for 4 consecutive minutes\n\nc.        Trips with a distance less than .1 miles\n\n6.        Prizes will vary and are dependent upon what local businesses and organizations can and will give. The Columbus-Phenix City MPO and Columbus Consolidated Government will not be held responsible for variations in prizes. Prizes are not cash refundable.\n\n7.        By clicking \"I Agree\", you also agree to public release of any images collected while using the app for lawful purposes, including but not limited to, publicity, publication on social media, in press releases, and in study literature. Contests winners will be publicly announced and publicized.\n\n8.        The Columbus-Phenix City MPO and Columbus Consolidated Government shall not be held responsible for any damage to personal property or bodily harm caused as a result of the use of this app. Please pull off to the side and out of the way of vehicles and pedestrians before using this app. Always abide by federal, state, and local laws regarding bicycling and always wear a proper fitting helmet.";

    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"contestAgreement"])
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Contest Agreement"
                                                                                 message:message
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        alertController.view.frame = [[UIScreen mainScreen] applicationFrame];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"I agree and want to enter the contest"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action){
                                                              [self agreed];
                                                          }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"I don't agree and don't want to enter the contest" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
            [self agreed];
        }]];

        [self presentViewController:alertController animated:YES completion:nil];
        
    }

    NSLog(@"%d", [[NSUserDefaults standardUserDefaults] boolForKey:@"contestAgreement"]);
}
-(void)agreed
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"contestAgreement"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
-(void)dontAgree
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"contestAgreement"];
    [[NSUserDefaults standardUserDefaults] synchronize];

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

// Grabs the json data from the website
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}


@end
