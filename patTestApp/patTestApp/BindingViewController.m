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
#import "MenuItem.h"

@interface BindingViewController ()

@end

static NSString *kPayPalLocationID = @"ANUSSV6QYPG3G"; //This is Josh's P@T Test location ID
static NSString *kPayPalBaseURL = @"https://api.paypal.com/retail/customer/v1/locations/";
static NSString *kMicrosBindBaseURL = @"https://pat-cloud-dev.mpaymentgateway.com/cloud/api/appBind/";
static NSString *kMicrosStatusBaseURL = @"https://pat-cloud-dev.mpaymentgateway.com/cloud/api/status/";
static NSString *kMicrosPayURL = @"https://pat-cloud-dev.mpaymentgateway.com/cloud/api/payment";

@implementation BindingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.buttonCancel.enabled = FALSE;

}

- (void) viewWillDisappear:(BOOL)animated
{
    NSLog(@"View Hidden......");
}

- (void)viewWillAppear:(BOOL)animated
{
    //pull access token from delegate
    self.accessToken = [(AppDelegate *)[[UIApplication sharedApplication] delegate] accessToken];
    
    //hide the spinner
    self.spinnerCode.hidden = TRUE;
    
    //initialize Bool w/ false
    self.bSetCode = FALSE;
    
    //init the array of items
    self.menuItems = [[NSMutableArray alloc] init];
    
    //if we made it here without an access token, prompt user
    if(!self.accessToken){
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
    self.myTimer = [NSTimer scheduledTimerWithTimeInterval:5
                                     target:self
                                   selector:@selector(tick:)
                                   userInfo:nil
                                    repeats:YES];
}

//timer tick function.  This allows us to ping Micros
- (void) tick:(NSTimer *) timer {
    
    if (self.bSetCode)
    {
        NSArray *custObj = [self.response objectForKey:@"customers"];
        
        if ([self.response objectForKey:@"customers"])
        {
            for ( NSDictionary *obj in custObj)
            {
                NSLog(@"----");
                NSLog(@"Code: %@", obj[@"customer_code"] );
                NSLog(@"----");
                
                if (obj[@"customer_code"])
                {
                    self.bindingCode = obj[@"customer_code"];
                    self.txtBindingCode.text = self.bindingCode;
                    self.bSetCode = FALSE;
                    self.spinnerCode.hidden = TRUE;
                    break;
                }
            }
        }
        if ([self.response objectForKey:@"table"])
        {
            self.bSetCode = FALSE;
            self.spinnerCode.hidden = TRUE;
        }
        
    }

    if (!self.bSetCode)
    {
        //create the full URL
        NSString *url1 = [kMicrosStatusBaseURL stringByAppendingString:kPayPalLocationID];
        NSString *url2 = [NSString stringWithFormat:@"%@%@%@%@%@%@",url1, @"/", self.customerID, @"/", self.tabID, @"/"];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
        [manager GET:url2
          parameters:nil
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 self.response = responseObject;
                 NSError *error = nil;
                 
                 NSLog(@"----");
                 NSLog(@"Checking for items");
                 NSLog(@"----");
                 
                 NSDictionary *tableObj = [self.response objectForKey:@"table"];
                 
                 if ([tableObj count] != 0)
                 {
                     NSArray *items = tableObj[@"items"];
                     
                     //NSLog(@"Here is the array: %@", items);
                     MenuItem *newItem = [[MenuItem alloc] init];
                     
                     //this is here for if we ever want to actually clean up that data
                     for (id item in items)
                     {
                         newItem.itemName = [items valueForKey:@"name"];
                         newItem.itemQty = [items valueForKey:@"quantity"];
                         newItem.itemPrice = [items valueForKey:@"unitPrice"];
                         
                         [self.menuItems addObject:newItem];
                         
                         NSLog(@"Here is item:  %@", newItem.itemName);
                     }
                     
                     //convert object to data
                     NSData* jsonData = [NSJSONSerialization dataWithJSONObject:[[responseObject objectForKey:@"table"] objectForKey:@"items"]
                     options:NSJSONWritingPrettyPrinted error:&error];
                     
                     self.txtStatus.text = [[NSString alloc] initWithData:jsonData
                                                              encoding:NSUTF8StringEncoding];
                     
                     self.buttonPay.enabled = TRUE;
                     
                 }

                 
                 
             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 NSLog(@"Error: %@", error);
             }];
        
    }
  
    NSLog(@"Tick!");
}

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
    //set up access token
    NSMutableString *token = [[NSMutableString alloc] initWithString:@"Bearer "];
    [token appendString:self.accessToken];
    
    //set up the URL
    NSString *url1 = [kPayPalBaseURL stringByAppendingString:kPayPalLocationID];
    NSString *url2 = [url1 stringByAppendingString:@"/tabs"];
    NSURL *endUrl = [NSURL URLWithString:url2];
    
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
    
    //convert the dictionary to JSON
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&jsonError];
    
    //did the json get created properly?
    if (! jsonData) {
        NSLog(@"-----");
        NSLog(@"Got an error creating JSON body for PayPal Check In: %@", jsonError);
        NSLog(@"-----");
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"jsonArray - %@",jsonString);
    }
    [request setHTTPBody:jsonData];
    
    // create network operation
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"It Worked!!!!!");
        
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
    //set up the call to PayPal
    //set up access token
    NSMutableString *token = [[NSMutableString alloc] initWithString:@"Bearer "];
    [token appendString:self.accessToken];
    
    //set up the URL
    NSString *url1 = [kPayPalBaseURL stringByAppendingString:kPayPalLocationID];
    NSString *url2 = [url1 stringByAppendingString:@"/tab/"];
    NSString *url3 = [url2 stringByAppendingString:self.tabID];
    NSURL *endUrl = [NSURL URLWithString:url3];
    
    //set up the request
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
        NSLog(@"-----");
        NSLog(@"Deleted Tab Successfully");
        NSLog(@"-----");
        
        NSLog(@"JSON: %@", responseObject);
        
        self.customerID = (NSString *)[responseObject objectForKey:@"Not Checked In"];
        self.tabID = (NSString *)[responseObject objectForKey:@"Not Checked In"];
        
        //set the text fields and UI elements
        self.txtCustId.text = self.customerID;
        self.txtTabId.text = self.tabID;
        self.buttonCheckIn.enabled = TRUE;
        self.buttonCancel.enabled = FALSE;
        self.txtBindingCode.text = @"-";
        
        [self.myTimer invalidate];
        
        self.spinnerCode.hidden = TRUE;
        
        self.txtStatus.text = @"";
        
        //show alert
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
    
    //set up HTTP request
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager GET:url2
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             //let's see what we get back as a response
             //NSLog(@"JSON returned from check in: %@", responseObject);
             //it worked, get the binding code from Micros
             [self getCodeFromMicros];
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             NSLog(@"-----");
             NSLog(@"Error checking in to Micros: %@", error);
             NSLog(@"-----");
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

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager GET:url2
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"JSON: %@", responseObject);
             self.bSetCode= TRUE;
             self.response = responseObject;
             
             self.spinnerCode.hidden = FALSE;
             
            [self startTimer];
             
       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MakePayment"]) {
        
        UINavigationController *navigationController = segue.destinationViewController;
        PaymentViewController *paymentViewController = [navigationController viewControllers][0];
        paymentViewController.custID = self.customerID;
        paymentViewController.tabID = self.tabID;
        paymentViewController.delegate = self;
    }
}

#pragma mark - PaymentViewControllerDelegate

- (void)paymentViewControllerDidCancel:(PaymentViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)paymentViewControllerDidSave:(PaymentViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
