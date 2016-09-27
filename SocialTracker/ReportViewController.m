//
//  ReportViewController.m
//  SocialTracker
//
//  Created by Admin on 9/25/16.
//  Copyright © 2016 Path Pair. All rights reserved.
//

#import "ReportViewController.h"
#import "Http/ServiceEngine.h"

@interface ReportViewController ()

@end

@implementation ReportViewController {
    
    UIToolbar *_toolbar;
    NSUInteger _type;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.types = @[@"Bad behavior", @"False profile", @"Inappropriate picture", @"Scam"];
    
    _toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)]; //toolbar is uitoolbar object
    _toolbar.barStyle = UIBarStyleDefault;
    UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(buttonDone:)];
    [_toolbar setItems:[NSArray arrayWithObject:btnDone]];
    
    self.textReason.delegate = self;
    
    self.buttonCancel.target = self;
    self.buttonCancel.action = @selector(cancelButtonPressed);

    self.buttonSend.target = self;
    self.buttonSend.action = @selector(sendButtonPressed);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    [self.textReason setInputAccessoryView:_toolbar];
    return YES;
}

- (IBAction)buttonDone:(id)sender {
    [self.view endEditing:YES];
}

- (void)cancelButtonPressed {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)sendButtonPressed {
    
    [[ServiceEngine sharedEngine] reportScam:self.contact.uid
                                   andReason:self.textReason.text
                                     andType:_type
                                   doneBlock:^(NSError * _Nullable error) {
                                       if (error == nil)
                                           [self.navigationController popViewControllerAnimated:YES];
                                   }];
    
}

#pragma mark -
#pragma mark PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component {
    return _types.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component {
    return _types[row];
}

#pragma mark -
#pragma mark PickerView Delegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component {
    _type = row;
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
