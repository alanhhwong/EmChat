//
//  TakePhotoViewController.m
//  EmChat
//
//  Created by Alan Wong on 14/3/15.
//  Copyright (c) 2015 Alan Wong. All rights reserved.
//

#import "TakePhotoViewController.h"
#import "UIActionSheet+Blocks.h"

@interface TakePhotoViewController ()

@property (weak, nonatomic) IBOutlet UITextField *screenNameTextField;
@property (weak, nonatomic) IBOutlet UIButton *profileImageButton;
@end

@implementation TakePhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)takePhotoButtonPressed:(id)sender {
    [UIActionSheet showInView:self.view withTitle:@"Add Photo" cancelButtonTitle:@"Cancel"destructiveButtonTitle:nil otherButtonTitles:@[@"Take Photo", @"Choose Photo"] tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
        if (buttonIndex != actionSheet.cancelButtonIndex) {
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.delegate = self;
                picker.allowsEditing = YES
            ;
                picker.sourceType = buttonIndex == 0 ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary;
                
                [self presentViewController:picker animated:YES completion:NULL];
        }
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    [self.profileImageButton setImage:chosenImage forState:UIControlStateNormal];
    
    self.profileImageButton.layer.cornerRadius = CGRectGetHeight(self.profileImageButton.frame)/2;
    self.profileImageButton.layer.masksToBounds = YES;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
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
