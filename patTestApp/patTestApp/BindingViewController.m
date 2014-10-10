//
//  BillViewController.m
//  patTestApp
//
//  Created by Hirschhorn Jr, Karl on 10/9/14.
//  Copyright (c) 2014 PayPal. All rights reserved.
//

#import "BindingViewController.h"
#import "AppDelegate.h"
#import "AFNetworking/AFNetworking.h"

@interface BindingViewController ()

@end

static NSString *kPayPalLocationID = @"ANUSSV6QYPG3G";
static NSString *kPayPalBaseURL = @"https://api.paypal.com/retail/customer/v1/locations/";
static NSString *kMicrosBindBaseURL = @"https://pat-cloud-dev.mpaymentgateway.com/cloud/api/appBind/";
static NSString *kMicrosStatusBaseURL = @"https://pat-cloud-dev.mpaymentgateway.com/cloud/api/status/";

@implementation BindingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.buttonCancel.enabled = FALSE;

}

- (void)viewWillAppear:(BOOL)animated
{
    NSString *accessToken = [(AppDelegate *)[[UIApplication sharedApplication] delegate] accessToken];
    
    if(!accessToken){
        [self showAlertWithTitle:@"Error" andMessage:@"You are not logged in, head to the login tab."];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)btnCheckIn:(id)sender
{
    //call helper method to create the check in
    [self createCheckIn];
}

- (IBAction)btnCancel:(id)sender {
    
    //call helper method to cancel check in
    [self deleteCheckIn];
}

- (void) startTimer {
    [NSTimer scheduledTimerWithTimeInterval:5
                                     target:self
                                   selector:@selector(tick:)
                                   userInfo:nil
                                    repeats:YES];
}

- (void) tick:(NSTimer *) timer {
    
    if (self.bSetCode)
    {
        NSArray *code = self.response[@"customers"];
        
        for ( NSDictionary *obj in code)
        {
            NSLog(@"----");
            NSLog(@"Code: %@", obj[@"customer_code"] );
            NSLog(@"----");
            
            
            if (obj[@"customer_code"])
            {
                self.bindingCode = obj[@"customer_code"];
                self.txtBindingCode.text = self.bindingCode;
                self.bSetCode = FALSE;
                break;
            }
            
        }
    }
    
    if (!self.bSetCode)
    {
        //create the full URL
        NSString *url1 = [kMicrosStatusBaseURL stringByAppendingString:kPayPalLocationID];
        NSString *url2 = [NSString stringWithFormat:@"%@%@%@%@%@%@",url1, @"/", self.customerID, @"/", self.tabID, @"/"];
        NSURL *endUrl = [NSURL URLWithString:url2];
        
        [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:endUrl] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            
            if (error) {
                [self fetchingGroupsFailedWithError:error];
            } else {
                NSLog(@"Checking for items.....");
                
                //NSLog(@"Response: %@", response);
                
                NSError *error = nil;
                NSDictionary *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                self.response = jsonArray;
                
                if (error != nil) {
                    NSLog(@"Error parsing JSON.");
                }
                else {
                    NSLog(@"Array: %@", jsonArray);
                    
                    NSArray *items = self.response[@"table.items"];
                    
                    self.txtStatus.text = items[0];
                }
            }
        }];
    }
  
    NSLog(@"Tick!");
}



/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

-(void) showAlertWithTitle:(NSString *)title andMessage:(NSString *)message
{
    UIAlertView *alertView =
    [[UIAlertView alloc]
     initWithTitle:title
     message: message
     delegate:self
     cancelButtonTitle:@"OK"
     otherButtonTitles:nil];
    [alertView show];
}

- (void)createCheckIn
{
    
    NSString *accessToken = [(AppDelegate *)[[UIApplication sharedApplication] delegate] accessToken];
    
    // 1
    NSString *url1 = [kPayPalBaseURL stringByAppendingString:kPayPalLocationID];
    NSString *url2 = [url1 stringByAppendingString:@"/tabs"];
    NSURL *endUrl = [NSURL URLWithString:url2];
    
    NSMutableString *token = [[NSMutableString alloc] initWithString:@"Bearer "];
    [token appendString:accessToken];
    
    //create request and headers
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:endUrl];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:token forHTTPHeaderField:@"Authorization"];
    
    //create body - Be sure to change the lat/long if for the location you wish to check into
    NSMutableDictionary *dictionary =
    [NSMutableDictionary dictionaryWithDictionary:@{
                                                    @"locationId" : kPayPalLocationID,
                                                    @"latitude" : @40.208774, //Hamilton Township NJ
                                                    @"longitude" : @-74.684162 //Hamilton Township NJ
                                                    }];
    
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&jsonError];
    
    if (! jsonData) {
        NSLog(@"Got an error: %@", jsonError);
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"jsonArray - %@",jsonString);
    }
    [request setHTTPBody:jsonData];
    
    // create network operation
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"It WOrked!!!!!");
        
        NSLog(@"JSON: %@", responseObject);
        
        //grab needed values
        self.customerID = (NSString *)[responseObject objectForKey:@"customerId"];
        self.tabID = (NSString *)[responseObject objectForKey:@"id"];
        self.tabExtensionURL = (NSString *)[responseObject objectForKey:@"tabExtensionUrl"];
        
        //set the text fields and UI elements
        self.txtCustId.text = self.customerID;
        self.txtTabId.text = self.tabID;
        self.buttonCheckIn.enabled = FALSE;
        self.buttonCancel.enabled = TRUE;
        
        //call Micros
        [self getCheckInWithCustomerID:self.customerID andTabID:self.tabID];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alertView;
        alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Unable to Check In." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        
        NSLog(@"%@",[error localizedDescription]);
    }];
    
    // start operation
    [operation start];
}

-(void) deleteCheckIn
{
    NSString *accessToken = [(AppDelegate *)[[UIApplication sharedApplication] delegate] accessToken];
    
    NSString *url1 = [kPayPalBaseURL stringByAppendingString:kPayPalLocationID];
    NSString *url2 = [url1 stringByAppendingString:@"/tab/"];
    NSString *url3 = [url2 stringByAppendingString:self.tabID];
    NSURL *endUrl = [NSURL URLWithString:url3];
    
    NSMutableString *token = [[NSMutableString alloc] initWithString:@"Bearer "];
    [token appendString:accessToken];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:endUrl];
    [request setHTTPMethod:@"DELETE"];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:token forHTTPHeaderField:@"Authorization"];
    
    // create network operation
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.securityPolicy.SSLPinningMode = AFSSLPinningModeNone;
    operation.securityPolicy.allowInvalidCertificates = YES;
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Deleted Tab Successfully");
        
        NSLog(@"JSON: %@", responseObject);
        
        self.customerID = (NSString *)[responseObject objectForKey:@"Not Checked In"];
        self.tabID = (NSString *)[responseObject objectForKey:@"Not Checked In"];
        
        //set the text fields and UI elements
        self.txtCustId.text = self.customerID;
        self.txtTabId.text = self.tabID;
        self.buttonCheckIn.enabled = TRUE;
        self.buttonCancel.enabled = FALSE;
        
        self.txtBindingCode.text = @"-";
        
        UIAlertView *alertView;
        alertView = [[UIAlertView alloc] initWithTitle:@"PayPal" message:@"You were Checked Out" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alertView;
        alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Problem Checking Out" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        
        NSLog(@"%@",[error localizedDescription]);
    }];
    
    [operation start];
}

//This will start the process and trigger calling the /status method
-(void)getCheckInWithCustomerID:(NSString*)custID andTabID:(NSString*)tabID
{
    //create the full URL
    NSString *url1 = [kMicrosBindBaseURL stringByAppendingString:kPayPalLocationID];
    NSString *url2 = [NSString stringWithFormat:@"%@%@%@%@%@%@",url1, @"/", self.customerID, @"/", self.tabID, @"/"];
    NSURL *endUrl = [NSURL URLWithString:url2];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager GET:url2
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"JSON: %@", responseObject);
             [self getCodeFromMicros];
         }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
         }
     ];
    
}

-(void)getCodeFromMicros
{
    //create the full URL
    NSString *url1 = [kMicrosStatusBaseURL stringByAppendingString:kPayPalLocationID];
    NSString *url2 = [NSString stringWithFormat:@"%@%@%@%@%@%@",url1, @"/", self.customerID, @"/", self.tabID, @"/"];
    NSURL *endUrl = [NSURL URLWithString:url2];
    
    NSLog(@"%@", endUrl);
    
    [self startTimer];
    
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:endUrl] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            [self fetchingGroupsFailedWithError:error];
        } else {
            NSLog(@"YAY!!!!!!!!!");
            
            self.bSetCode= TRUE;
            
            NSLog(@"Response: %@", response);
            
            NSError *error = nil;
            NSDictionary *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            self.response = jsonArray;
            
            if (error != nil) {
                NSLog(@"Error parsing JSON.");
            }
            else {
                NSLog(@"Array: %@", jsonArray);
            }
        }
    }];
    
  
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:endUrl];
//    [request setHTTPMethod:@"GET"];
//    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//    [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
//    
//    // create network operation
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    operation.responseSerializer = [AFJSONResponseSerializer serializer];
//    
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"Got a Code!!!!!");
//        
//        NSLog(@"JSON: %@", responseObject);
//        
//        self.bindingCode = (NSString *)[responseObject objectForKey:@"customer_code"];
//        
//        self.txtBindingCode.text = self.bindingCode;
//        self.txtAcknowledge.enabled = TRUE;
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        UIAlertView *alertView;
//        alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Problem calling Micros to get code" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alertView show];
//        
//        NSLog(@"%@",[error localizedDescription]);
//    }];
//    
//    [operation start];
}

#pragma mark - MeetupCommunicatorDelegate



- (void)fetchingGroupsFailedWithError:(NSError *)error
{
    [self fetchingGroupsFailedWithError:error];
}


@end
