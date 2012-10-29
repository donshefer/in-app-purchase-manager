//
//  InAppPurchaseManager.h
//
//  Created by Don Shefer on 9/6/12.
//  Based on examples found online
//  No rights reserved.
//

#import "InAppPurchaseManager.h"
#import "Reachability.h"

@implementation InAppPurchaseManager

@synthesize delegate;

// Public Methods
static InAppPurchaseManager *_sharedInAppManager = nil;

+ (InAppPurchaseManager *)sharedInAppManager
{
	@synchronized([InAppPurchaseManager class])
	{
		if (!_sharedInAppManager)
			[[self alloc] init];
		
		return _sharedInAppManager;
	}
	// to avoid compiler warning
	return nil;
}

+(id)alloc
{
	@synchronized([InAppPurchaseManager class])
	{
		NSAssert(_sharedInAppManager == nil, @"Attempted to allocate a second instance of a singleton.");
		_sharedInAppManager = [super alloc];
		return _sharedInAppManager;
	}
	// to avoid compiler warning
	return nil;
}

-(id) init
{
	storeDoneLoading = NO;
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

- (BOOL) storeLoaded
{
	return storeDoneLoading;
}

//
// call this method once on startup
//
- (void)loadStore
// Run this in the AppDelegate on app start
{
    // restarts any purchases if they were interrupted last time the app was open
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
}

//
// call this before making a purchase
//
- (BOOL)canMakePurchases
{
    return [SKPaymentQueue canMakePayments];
}


#pragma mark -
#pragma mark - Kick off the transaction

- (void)purchaseItemWithProductID:(NSString *)productID {
    
    if([self checkNetwork])
	{
        SKPayment *payment = [SKPayment paymentWithProductIdentifier:productID];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
        
    }
    
}

#pragma mark -
#pragma mark - Provide content
- (void)provideContent:(NSString *)productId
// This is where you enable the purchased content
{
    
    if ([productId isEqualToString:@"product_1"]) {
    
        // enable the features
    
    
    } else if ([productId isEqualToString:@"product_2"]) {
        
        // enable the features
    
    }
    
    // Show user something
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Congratulations"
                                                      message:@"Your purchase has been enabled."
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    
    [message show];
    [message release];
    
}

//
// removes the transaction from the queue and posts a notification with the transaction result
//
- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful
{
    // remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:transaction, @"transaction" , nil];
    if (wasSuccessful)
    {
        // send out a notification that we’ve finished the transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionSucceededNotification object:self userInfo:userInfo];
    }
    else
    {
        // send out a notification for the failed transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionFailedNotification object:self userInfo:userInfo];
    }
}

//
// called when the transaction was successful
//
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    [self provideContent:transaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}

//
// called when a transaction has been restored and and successfully completed
//
- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    [self provideContent:transaction.originalTransaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}

//
// called when a transaction has failed
//
- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // error!
        NSLog(@"Transaction error: %@",transaction.error.localizedDescription);
        NSLog(@"Transaction description: %@",transaction.error.description);
        NSLog(@"Transaction code: %d",transaction.error.code);
        
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Transaction Error"
                                                          message:transaction.error.localizedDescription
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
        [message release];
        
        [self finishTransaction:transaction wasSuccessful:NO];
        
        
    }
    else
    {
        // this is fine, the user just cancelled, so don’t notify
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}
// Connectivity Helpers
- (BOOL) connectedToNetwork
{
	Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
	NetworkStatus internetStatus = [r currentReachabilityStatus];
	BOOL internet;
	if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN)) {
		internet = NO;
	} else {
		internet = YES;
	}
	return internet;
}

- (BOOL) checkNetwork
{
    if([self connectedToNetwork] != YES)
	{
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"No Internet Connection"
                                                          message:@"You need to be connected to the internet to make a purchase."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
        [message release];
        return NO;
        
	} else if ([self canMakePurchases] != YES) {
        
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"In-App Purchases are Disabled"
                                                          message:@"Please enable IAP in settings and make sure you have internet."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
        [message release];
        return NO;
        
    } else {
        
        return YES;
    }
    
}

#pragma mark -
#pragma mark SKPaymentTransactionObserver methods

//
// called when the transaction status is updated
//
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

@end
