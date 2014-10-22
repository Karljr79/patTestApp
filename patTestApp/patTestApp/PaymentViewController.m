//
//  PaymentViewController.m
//  patTestApp
//
//  Created by Hirschhorn Jr, Karl on 10/14/14.
//  Copyright (c) 2014 PayPal. All rights reserved.
//

#import "PaymentViewController.h"
#import "AFNetworking/AFNetworking.h"

static NSString *kMicrosPayURL = @"https://pat-cloud-dev.mpaymentgateway.com/cloud/api/payment";

@implementation PaymentViewController

- (void) viewWillAppear:(BOOL)animated
{
    //for demo purposes just make this a dollar
    self.fSubTotal = [NSNumber numberWithDouble:1.00];
    self.fTipAmount = [NSNumber numberWithDouble:0.00];
    self.fTotal = @([self.fSubTotal doubleValue] + [self.fTipAmount doubleValue]);
    NSLog(@"Here is the total: %@", [self.fTotal.stringValue stringByAppendingString:@".00"]);
}

- (IBAction)btn10:(id)sender {
    self.fTipAmount = [NSNumber numberWithDouble:0.10];
    [self updateDisplay];
}

- (IBAction)btn15:(id)sender {
    self.fTipAmount = [NSNumber numberWithDouble:0.20];
    [self updateDisplay];
}

- (IBAction)btn20:(id)sender {
    self.fTipAmount = [NSNumber numberWithDouble:0.30];
    [self updateDisplay];
}

- (IBAction)cancel:(id)sender
{
    [self.delegate paymentViewControllerDidCancel:self];
}
- (IBAction)confirm:(id)sender
{
    if (self.tabID && self.custID)
    {
        [self payMicrosTab:^(BOOL flag) {
            if (flag) {
                [self performSegueWithIdentifier:@"Success" sender:self];
            }
            else{
                [self showAlertWithTitle:@"PayPal" andMessage:@"Payment Failed, please try again"];
            }
        }];
        
    }
    else
    {
        [self showAlertWithTitle:@"PayPal" andMessage:@"App is in a wierd state and you should never have made it this far!!!"];
    }
}

- (void)updateDisplay
{
    self.fTotal = @([self.fSubTotal doubleValue] + [self.fTipAmount doubleValue]);
    self.txtSubTotal.text = [self.fSubTotal.stringValue stringByAppendingString:@".0"];
    self.txtTip.text = [self.fTipAmount.stringValue stringByAppendingString:@".0"];
    self.txtTotal.text = [self.fTotal.stringValue stringByAppendingString:@".0"];
}

- (IBAction)btnNone:(id)sender {
    self.fTipAmount = [NSNumber numberWithDouble:0.00];
}

-(void) showAlertWithTitle:(NSString *)title andMessage:(NSString *)message
{
    UIAlertView *alertView =
    [[UIAlertView alloc]
     initWithTitle:title
     message: message
     delegate:self
     cancelButtonTitle:@"OK"
     otherButtonTitles:nil];
    [alertView show];
}

-(void)payMicrosTab:(void (^)(BOOL flag))completionHandler
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    NSDictionary *params = @{@"payment[sub_total]": self.fSubTotal.stringValue,
                             @"payment[tax]": @"0.00",
                             @"payment[total]": [self.fTotal.stringValue stringByAppendingString:@"0"],
                             @"payment[tip]":[self.fTipAmount.stringValue stringByAppendingString:@".0"],
                             @"payment[type]": @"TablePayment",
                             @"pp_customer_id": self.custID,
                             @"split_type": @"",
                             @"pp_tab_id": self.tabID
                             };
    [manager POST:kMicrosPayURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Payment Response: %@", responseObject);
        
        completionHandler(YES);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error making Payment: %@", error);
        
        completionHandler(NO);
    }];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Success"]) {
        
       
    }
}

@end
