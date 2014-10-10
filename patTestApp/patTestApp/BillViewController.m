//
//  BillViewController.m
//  patTestApp
//
//  Created by Hirschhorn Jr, Karl on 10/9/14.
//  Copyright (c) 2014 PayPal. All rights reserved.
//

#import "BillViewController.h"
#import "AppDelegate.h"
#import "AFNetworking/AFNetworking.h"

static NSString * const BaseURLString = @"https://api.paypal.com/retail/customer/v1/locations/";

@interface BillViewController ()

@end

@implementation BillViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.prodEndpoint = @"https://api.paypal.com/retail/customer/v1/locations";
}

- (void)viewWillAppear:(BOOL)animated
{
    NSString *accessToken = [(AppDelegate *)[[UIApplication sharedApplication] delegate] accessToken];
    
    if(!accessToken){
        UIAlertView *alertView;
        alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You are not logged in, head to the login tab." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnCheckIn:(id)sender {
    
    NSString *locationID = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"locationID"];
    NSString *accessToken = [(AppDelegate *)[[UIApplication sharedApplication] delegate] accessToken];
    
    // 1
    NSString *string2 = [BaseURLString stringByAppendingString:locationID];
    NSString *string3 = [string2 stringByAppendingString:@"/tabs"];
    
    NSMutableString *token = [[NSMutableString alloc] initWithString:@"Bearer "];
    [token appendString:accessToken];
    
    NSURL *url = [NSURL URLWithString:string3];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:token forHTTPHeaderField:@"Authorization"];
    
    NSMutableDictionary *dictionary =
    [NSMutableDictionary dictionaryWithDictionary:@{
                                                    @"locationId" : locationID,
                                                    @"latitude" : @40.208774,
                                                    @"longitude" : @-74.684162
                                                    }];

    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&jsonError];
    
    if (! jsonData) {
        NSLog(@"Got an error: %@", jsonError);
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"jsonArray - %@",jsonString);
    }
    
    [request setHTTPBody:jsonData];
    
    // 2
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"It WOrked!!!!!");
        
        NSLog(@"JSON: %@", responseObject);
        
        //set the text fields
        self.txtCustId.text = (NSString *)[responseObject objectForKey:@"customerId"];
        self.txtTabId.text = (NSString *)[responseObject objectForKey:@"id"];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alertView;
        alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Unable to Check In." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        
        NSLog(@"%@",[error localizedDescription]);
    }];
    
    [operation start];
}


- (NSMutableURLRequest *)createLoginRequest {
    
    NSString *locationID = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"locationID"];
    NSString *accessToken = [(AppDelegate *)[[UIApplication sharedApplication] delegate] accessToken];

    
    NSMutableString *urlString = [[NSMutableString alloc] initWithString:_prodEndpoint];
    [urlString appendString:@"/locations/"];
    [urlString appendString:locationID];
    [urlString appendString:@"/tab"];
    
    NSMutableString *token = [[NSMutableString alloc] initWithString:@"Bearer "];
    [token appendString:accessToken];
    
    NSMutableURLRequest *checkInRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    
    [checkInRequest setHTTPMethod:@"POST"];
    
    [checkInRequest setValue:token forHTTPHeaderField:@"Authorization"];
    [checkInRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    return checkInRequest;
}

@end
