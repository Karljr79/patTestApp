//
//  PaymentViewController.h
//  patTestApp
//
//  Created by Hirschhorn Jr, Karl on 10/14/14.
//  Copyright (c) 2014 PayPal. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PaymentViewController;

@protocol PaymentViewControllerDelegate <NSObject>
- (void)paymentViewControllerDidCancel:(PaymentViewController *)controller;
- (void)paymentViewControllerDidSave:(PaymentViewController *)controller;
@end

@interface PaymentViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UIButton *button10;
@property (weak, nonatomic) IBOutlet UIButton *button15;
@property (weak, nonatomic) IBOutlet UIButton *button20;
@property (weak, nonatomic) IBOutlet UIButton *buttonNone;
@property (nonatomic, weak) id <PaymentViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *txtSubTotal;
@property (weak, nonatomic) IBOutlet UILabel *txtTip;
@property (weak, nonatomic) IBOutlet UILabel *txtTotal;
@property (weak, nonatomic) NSNumber *fSubTotal;
@property (weak, nonatomic) NSNumber *fTipAmount;
@property (weak, nonatomic) NSNumber *fTotal;

- (IBAction)btn10:(id)sender;
- (IBAction)btn15:(id)sender;
- (IBAction)btn20:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)confirm:(id)sender;
- (IBAction)btnNone:(id)sender;

@end