//
//  SuccessViewController.m
//  patTestApp
//
//  Created by Hirschhorn Jr, Karl on 10/16/14.
//  Copyright (c) 2014 PayPal. All rights reserved.
//

#import "SuccessViewController.h"

@implementation SuccessViewController

- (IBAction)btnSuccess:(id)sender {
    [self.presentingViewController.presentingViewController dismissModalViewControllerAnimated:YES];
}
@end
