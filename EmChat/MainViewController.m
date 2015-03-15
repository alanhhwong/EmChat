//
//  MainViewController.m
//  EmChat
//
//  Created by Alan Wong on 15/3/15.
//  Copyright (c) 2015 Alan Wong. All rights reserved.
//

#import "MainViewController.h"
#import "AFNetworking.h"
#import "MainTableViewCell.h"
#import "Interest.h"
#import "Attraction.h"
#import "UIImageView+WebCache.h"
#import <LayerKit/LayerKit.h>
#import "AppDelegate.h"
#import "Atlas.h"
#import "ATLMConversationViewController.h"
#import <UIKit/UIKit.h>


@interface MainViewController ()

@property NSMutableArray *personArray;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //load array
    _personArray = [NSMutableArray array];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSDictionary *params = [NSDictionary dictionaryWithObject:@"42" forKey:@"uid"];
    [manager POST:@"http://emchat.ngrok.com/list" parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSArray *responseArray = responseObject;
         for (NSDictionary* personDict in responseArray) {
             Person* person = [[Person alloc]initWithDictionary:personDict];
             [_personArray addObject:person];
         }

         [_tableView reloadData];
         NSLog(@"JSON: %@", responseObject);
     }
          failure:
     ^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
     }];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"MainTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MainTableViewCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_personArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MainTableViewCell *cell = (MainTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"MainTableViewCell" forIndexPath:indexPath];
    
    /*
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }*/
    Person *person = [_personArray objectAtIndex:indexPath.row];
    
    NSMutableAttributedString *interests = [[NSMutableAttributedString alloc]initWithString:@""];
    
    for (Interest* interest in person.interests) {
        NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:interest.name];
        if ([interest.match intValue] == 1) {
            [attrText addAttribute: NSFontAttributeName value: [UIFont fontWithName: @"Helvetica-Bold" size:12] range: NSMakeRange(0, [interest.name length])];
        }
        
        [interests appendAttributedString:[[NSAttributedString alloc] initWithString:@"#"]];
        [interests appendAttributedString:attrText];
        [interests appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    }

    NSMutableAttributedString *attractions = [[NSMutableAttributedString alloc]initWithString:@""];
    for (Attraction* attraction in person.attractions) {
        NSMutableAttributedString *attrText2 = [[NSMutableAttributedString alloc] initWithString:attraction.name];
        if ([attraction.match intValue] == 1) {
            [attrText2 addAttribute: NSFontAttributeName value: [UIFont fontWithName: @"Helvetica-Bold" size:12] range: NSMakeRange(0, [attraction.name length])];
        }
        
        [attractions appendAttributedString:[[NSAttributedString alloc] initWithString:@"#"]];
        [attractions appendAttributedString:attrText2];
        [attractions appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    }
    
    cell.name.text = person.display_name;
    cell.interests.attributedText = interests;
    cell.attractions.attributedText = attractions;
    
    [cell.customImageView sd_setImageWithURL:[NSURL URLWithString:person.original_img_url   ]];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    Person *person = [_personArray objectAtIndex:indexPath.row];
    LYRConversation *conversation = [appDelegate.applicationController conversationWithParticipants:[NSSet setWithObject:person._id]];
    
    ATLMConversationViewController *controller = [ATLMConversationViewController conversationViewControllerWithLayerClient:appDelegate.applicationController.layerClient];
    controller.conversation = conversation;
    controller.applicationController = appDelegate.applicationController;
    controller.displaysAddressBar = false;
    [self.navigationController pushViewController:controller animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
