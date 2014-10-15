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
}

- (IBAction)btn10:(id)sender {
}

- (IBAction)btn15:(id)sender {
}

- (IBAction)btn20:(id)sender {
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
}

@end
