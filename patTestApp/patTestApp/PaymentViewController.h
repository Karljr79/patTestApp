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

@property (nonatomic, weak) id <PaymentViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *button10, *button15, *button20, *buttonNone;
@property (weak, nonatomic) IBOutlet UILabel *txtSubTotal, *txtTip, *txtTotal;
@property (strong, nonatomic) NSNumber *fSubTotal, *fTipAmount, *fTotal;
@property (strong, nonatomic) NSString *tabID, *custID;

- (IBAction)btn10:(id)sender;
- (IBAction)btn15:(id)sender;
- (IBAction)btn20:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)confirm:(id)sender;
- (IBAction)btnNone:(id)sender;

@end