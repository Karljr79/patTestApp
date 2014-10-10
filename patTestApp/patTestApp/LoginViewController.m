//
//  ViewController.m
//  patTestApp
//
//  Created by Hirschhorn Jr, Karl on 10/9/14.
//  Copyright (c) 2014 PayPal. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    NSString *accessToken = [(AppDelegate *)[[UIApplication sharedApplication] delegate] accessToken];
    
    if(accessToken){
        UIAlertView *alertView;
        alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You are already logged in, head to the view bill tab." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//open the login screen
- (IBAction)btnLogin:(id)sender {
        NSURL *url = [NSURL URLWithString:@"http://www.jpgerber.com/karlapp/start.php"];
        
        if (![[UIApplication sharedApplication] openURL:url]) {
            NSLog(@"%@%@",@"Failed to open url:",[url description]);
        }
}
@end
