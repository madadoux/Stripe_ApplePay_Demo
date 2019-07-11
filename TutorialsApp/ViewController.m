//
//  ViewController.m
//  TutorialsApp
//
//  Created by mohamed saeed on 7/10/19.
//  Copyright © 2019 mohamed saeed. All rights reserved.
//

#import "ViewController.h"
#import <PassKit/PassKit.h>
#import <Stripe/Stripe.h>
#import <Stripe/Stripe+ApplePay.h>

@interface ViewController  () <PKPaymentAuthorizationViewControllerDelegate>

@end

@implementation ViewController
PKPaymentAuthorizationViewController *controller ;

NSString *ApplePaySwagMerchantID = @"merchant.laundrez"; // Fill in your merchant ID here!
NSString *stripeTestKey = @"pk_test_3zMkHjCQ7LmyBCH99vPFhAhC00IXjvORQX";

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)BuyElement:(id)sender {
   
  id SupportedPaymentNetworks = @[PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex];
    PKPaymentRequest *request = [[PKPaymentRequest alloc]init];
    request.merchantIdentifier = ApplePaySwagMerchantID;
    request.supportedNetworks = SupportedPaymentNetworks;
    request.merchantCapabilities = PKMerchantCapability3DS;
    request.countryCode = @"US";
    request.currencyCode = @"USD";
    PKPaymentSummaryItem *item1 = [PKPaymentSummaryItem summaryItemWithLabel:@"lol" amount:[NSDecimalNumber decimalNumberWithString:@"40.00"
                                                                                             ]];
    
    request.paymentSummaryItems = @[
                                    item1
                                    ];
    controller = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
    
    controller.delegate = self ;
    
    [self presentViewController:controller animated:true completion:^{}];
}
- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    [controller dismissViewControllerAnimated:true completion:nil];
}
-(void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller didAuthorizePayment:(PKPayment *)payment handler:(void (^)(PKPaymentAuthorizationResult * _Nonnull))completion {
    
    [Stripe setDefaultPublishableKey:stripeTestKey];
    
    [STPAPIClient.sharedClient createTokenWithPayment:payment completion:^(STPToken * _Nullable token, NSError * _Nullable error) {
        if (error != nil ) {
            completion([[PKPaymentAuthorizationResult alloc] initWithStatus:PKPaymentAuthorizationStatusFailure errors:nil]);

        }
        
        NSURL *url = [[NSURL alloc]initWithString:@"http://localhost:5000/pay"];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
        request.HTTPMethod = @"POST";
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
           [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
        NSDictionary *body = @{@"stripeToken": token.tokenId,
                               @"amount": @200,
                               @"description" :@"labala"};
        
        request.HTTPBody =  [NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingSortedKeys error:nil];

        [[NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error != nil){
                completion([[PKPaymentAuthorizationResult alloc] initWithStatus:PKPaymentAuthorizationStatusFailure errors:nil]);
            }
            else {
                completion([[PKPaymentAuthorizationResult alloc] initWithStatus:PKPaymentAuthorizationStatusSuccess errors:nil]);
                
            }
        }] resume];
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
