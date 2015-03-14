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
    
    NSString *interests = @"";
    for (Interest* interest in person.interests) {
        interests = [interests stringByAppendingString:interest.name];
        interests = [interests stringByAppendingString:@" "];
    }
    
    NSString *attractions = @"";
    for (Attraction* attraction in person.attractions) {
        attractions = [attractions stringByAppendingString:attraction.name];
        attractions = [attractions stringByAppendingString:@" "];
    }
    
    cell.name.text = person.display_name;
    cell.interests.text = interests;
    cell.attractions.text = attractions;
    
    //[cell.customImageView sd_setImageWithURL:[NSURL URLWithString:<#(NSString *)#>]]
    
    return cell;
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
