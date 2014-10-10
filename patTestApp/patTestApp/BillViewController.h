//
//  BillViewController.h
//  patTestApp
//
//  Created by Hirschhorn Jr, Karl on 10/9/14.
//  Copyright (c) 2014 PayPal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BillViewController : UIViewController
@property NSString *prodEndpoint;
@property (weak, nonatomic) IBOutlet UILabel *txtTabId;
@property (weak, nonatomic) IBOutlet UILabel *txtCustId;
- (IBAction)btnCheckIn:(id)sender;

@end
