//
//  BillViewController.h
//  patTestApp
//
//  Created by Hirschhorn Jr, Karl on 10/9/14.
//  Copyright (c) 2014 PayPal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BindingViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *txtTabId;
@property (weak, nonatomic) IBOutlet UILabel *txtCustId;
@property (weak, nonatomic) IBOutlet UIButton *buttonCheckIn;
@property (weak, nonatomic) IBOutlet UILabel *txtBindingCode;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonCancel;
@property (weak, nonatomic) IBOutlet UITextView *txtStatus;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinnerCode;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonPay;

@property (weak, nonatomic) NSString *customerID;
@property (weak, nonatomic) NSString *tabID;
@property (weak, nonatomic) NSString *bindingCode;
@property (weak, nonatomic) NSString *tabExtensionURL;
@property (weak, nonatomic) NSString *accessToken;
@property (strong, nonatomic) NSMutableArray *menuItems;
@property (strong, nonatomic) id response;
@property (nonatomic) BOOL bSetCode;
@property (nonatomic) NSTimer *myTimer;

- (IBAction)btnCheckIn:(id)sender;
- (IBAction)btnCancel:(id)sender;
- (IBAction)btnPayNow:(id)sender;

-(void) showAlertWithTitle:(NSString *)title andMessage:(NSString *)message;


@end
