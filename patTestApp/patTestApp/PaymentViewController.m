//
//  PaymentViewController.m
//  patTestApp
//
//  Created by Hirschhorn Jr, Karl on 10/14/14.
//  Copyright (c) 2014 PayPal. All rights reserved.
//

#import "PaymentViewController.h"

@implementation PaymentViewController

- (void) viewWillAppear:(BOOL)animated
{
    //for demo purposes just make this a dollar
    self.fSubTotal = [NSNumber numberWithDouble:1.00];
    self.fTipAmount = [NSNumber numberWithDouble:0.00];
    self.fTotal = @([self.fSubTotal doubleValue] + [self.fTipAmount doubleValue]);
}

- (IBAction)btn10:(id)sender {
    self.fTipAmount = [NSNumber numberWithDouble:0.10];
}

- (IBAction)btn15:(id)sender {
    self.fTipAmount = [NSNumber numberWithDouble:0.15];
}

- (IBAction)btn20:(id)sender {
    self.fTipAmount = [NSNumber numberWithDouble:0.20];
}

- (IBAction)cancel:(id)sender
{
    [self.delegate paymentViewControllerDidCancel:self];
}
- (IBAction)confirm:(id)sender
{
    [self.delegate paymentViewControllerDidSave:self];
}

- (IBAction)btnNone:(id)sender {
    self.fTipAmount = [NSNumber numberWithDouble:0.00];
}

@end
