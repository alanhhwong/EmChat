//
//  AttractionsSelectionViewController.m
//  EmChat
//
//  Created by Ashish Awaghad on 14/3/15.
//  Copyright (c) 2015 Alan Wong. All rights reserved.
//

#import "AttractionsSelectionViewController.h"
#import "AttractionTableViewCell.h"
#import "Attraction.h"
#import "AFNetworking.h"
#import "AppDelegate.h"

NSString const *USER_BASE_URL = @"http://emchat.ngrok.com/user";

@interface AttractionsSelectionViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *attractions;
@property (nonatomic, strong) NSMutableSet *selectedAttractions;

@end

@implementation AttractionsSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    _attractions = [@[@"Dubai Fountains", @"Burj Khalifa", @"Dubai Mall", @"Dubai Metro"] mutableCopy];
    _selectedAttractions = [NSMutableSet set];

    [self.tableView registerNib:[UINib nibWithNibName:@"AttractionTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"AttractionTableViewCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _attractions.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AttractionTableViewCell *cell = (AttractionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"AttractionTableViewCell" forIndexPath:indexPath];
    
    //    if (!cell) {
    //        cell = [[[NSBundle mainBundle] loadNibNamed:@"InterestTableViewCell" owner:self options:nil] firstObject];
    //    }
    // Configure the cell...

    cell.attractionLabel.text = _attractions[indexPath.row];
    cell.attractionImageView.image = [UIImage imageNamed:_attractions[indexPath.row]];
    cell.checkmarkButton.selected = [_selectedAttractions containsObject:_attractions[indexPath.row]];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([_selectedAttractions containsObject:_attractions[indexPath.row]]) {
        [_selectedAttractions removeObject:_attractions[indexPath.row]];
    }
    else {
        [_selectedAttractions addObject:_attractions[indexPath.row]];
    }
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}


- (IBAction)donePressed:(id)sender {
    
//    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
//    [delegate showMainWindow:self.me];
    
    NSMutableArray *attractionsArray = [NSMutableArray array];
    for (NSString* name in _selectedAttractions) {
        Attraction* attraction = [[Attraction alloc]init];
        attraction.name = name;
        attraction.match = @false;
        [attractionsArray addObject:attraction];
    }
    self.me.attractions = attractionsArray;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:USER_BASE_URL parameters:[self.me toDictionary]
          success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSLog(@"JSON: %@", responseObject);
        NSDictionary *responseDict = responseObject;
        self.me._id = [responseDict objectForKey:@"uid"];
     
        AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
        [delegate showMainWindow:self.me];
    }
          failure:
     ^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
     }];
}

@end
