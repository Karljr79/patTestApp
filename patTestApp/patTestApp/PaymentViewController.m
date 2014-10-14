//
//  PaymentViewController.m
//  patTestApp
//
//  Created by Hirschhorn Jr, Karl on 10/14/14.
//  Copyright (c) 2014 PayPal. All rights reserved.
//

#import "PaymentViewController.h"

@implementation PaymentViewController

- (IBAction)cancel:(id)sender
{
    [self.delegate paymentViewControllerDidCancel:self];
}
- (IBAction)confirm:(id)sender
{
    [self.delegate paymentViewControllerDidSave:self];
}

@end
