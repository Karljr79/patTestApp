//
//  PaymentViewController.h
//  patTestApp
//
//  Created by Hirschhorn Jr, Karl on 10/14/14.
//  Copyright (c) 2014 PayPal. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PaymentViewControllerDelegate;

@protocol PaymentViewControllerDelegate <NSObject>
- (void)paymentViewControllerDidCancel:(PaymentViewControllerDelegate *)controller;
- (void)paymentViewControllerDidSave:(PaymentViewControllerDelegate *)controller;
@end

@interface PaymentViewController : UITableViewController

@property (nonatomic, weak) id <PaymentViewControllerDelegate> delegate;

- (IBAction)cancel:(id)sender;
- (IBAction)confirm:(id)sender;

@end