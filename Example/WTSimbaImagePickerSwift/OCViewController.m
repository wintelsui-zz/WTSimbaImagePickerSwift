//
//  OCViewController.m
//  WTSimbaImagePickerDemo
//
//  Created by smalltalk on 25/3/2020.
//  Copyright © 2020 sfs. All rights reserved.
//

#import "OCViewController.h"
#import "WTSimbaImagePickerSwift-Swift.h"



@interface OCViewController ()
<WTSimbaImagePickerControllerDelegate>

@end

@implementation OCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)pickerButtonPressed:(id)sender {
    
    WTSimbaImagePickerController *picker = [[WTSimbaImagePickerController alloc] init];
    
    picker.pickerDelegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
    
}

#pragma mark - -- WTSimbaImagePickerControllerDelegate --
- (void)simbaImagePickerControllerDidFinishWithPicker:(WTSimbaImagePickerController *)picker
                                               images:(NSArray<PHAsset *> *)images
                                         editedImages:(NSDictionary<PHAsset *,WTSimbaImagePickerImageEditedModel *> *)editedImages{
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    NSLog(@"%@",images);
    NSLog(@"%@",editedImages);
}


@end
