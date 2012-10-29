//
//  InAppPurchaseManager.h
//
//  Created by Don Shefer on 9/6/12.
//  Based on examples found online
//  No rights reserved.
//

#import <StoreKit/StoreKit.h>

// add a couple notifications sent out when the transaction completes
#define kInAppPurchaseManagerTransactionFailedNotification @"kInAppPurchaseManagerTransactionFailedNotification"
#define kInAppPurchaseManagerTransactionSucceededNotification @"kInAppPurchaseManagerTransactionSucceededNotification" 

@interface InAppPurchaseManager : NSObject <SKPaymentTransactionObserver>
{
    BOOL storeDoneLoading;
}

// public methods
+(InAppPurchaseManager *)sharedInAppManager;

- (void)loadStore;
- (BOOL)canMakePurchases;
- (void)purchaseItemWithProductID:(NSString*)productID;

- (BOOL) connectedToNetwork;
- (BOOL) checkNetwork;

@end