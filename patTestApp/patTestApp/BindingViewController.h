//
//  BillViewController.h
//  patTestApp
//
//  Created by Hirschhorn Jr, Karl on 10/9/14.
//  Copyright (c) 2014 PayPal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaymentViewController.h"

@interface BindingViewController : UIViewController <PaymentViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *txtTabId, *txtCustId, *txtBindingCode, *txtBIllTotal;
@property (weak, nonatomic) IBOutlet UIButton *buttonCheckIn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonCancel, *buttonPay;
@property (weak, nonatomic) IBOutlet UITextView *txtStatus;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinnerCode;

@property (weak, nonatomic) NSString *customerID, *tabID, *bindingCode, *tabExtensionURL, *accessToken;
@property (strong, nonatomic) NSMutableArray *menuItems;
@property (strong, nonatomic) id response;
@property (nonatomic) BOOL bSetCode;
@property (nonatomic) NSTimer *myTimer;

- (IBAction)btnCheckIn:(id)sender;
- (IBAction)btnCancel:(id)sender;
- (void) showAlertWithTitle:(NSString *)title andMessage:(NSString *)message;


@end
