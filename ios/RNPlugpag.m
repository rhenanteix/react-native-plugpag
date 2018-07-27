#import "RNPlugpag.h"
#import "AppDelegate.h"

@implementation RNPlugpag

- (NSDictionary *)constantsToExport
{
    return @{ @"PAYMENT_CREDIT": @(CREDIT),
              @"PAYMENT_DEBIT": @(DEBIT),
              @"PAYMENT_VOUCHER": @(VOUCHER),
              @"INSTALLMENT_TYPE_A_VISTA" : @(A_VISTA),
              @"INSTALLMENT_TYPE_PARC_VENDEDOR" : @(PARC_VENDEDOR)};
}

RCT_EXPORT_METHOD(isAuthenticated:(NSDictionary *)request resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    NSString *appName = [RCTConvert NSString:request[@"appName"]];
    NSString *appVersion = [RCTConvert NSString:request[@"appVersion"]];
    [[PlugPag sharedInstance] plugPagAppIdentification:appName withVersion:appVersion];
    BOOL isAuthenticated = [[PlugPag sharedInstance] isAuthenticated];
    resolve(@{@"isAuthenticated": @(isAuthenticated)});
}

RCT_EXPORT_METHOD(requestAuthentication:(NSDictionary *)request resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    NSString *appName = [RCTConvert NSString:request[@"appName"]];
    NSString *appVersion = [RCTConvert NSString:request[@"appVersion"]];
    dispatch_sync(dispatch_get_main_queue(), ^{
        UIViewController *rootViewController = UIApplication.sharedApplication.delegate.window.rootViewController;
        
        [[PlugPag sharedInstance] plugPagAppIdentification:appName withVersion:appVersion];
        [[PlugPag sharedInstance] requestAuthentication:rootViewController];
    });
}

RCT_EXPORT_METHOD(checkout:(NSDictionary *)request resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    NSString *appName = [RCTConvert NSString:request[@"appName"]];
    NSString *appVersion = [RCTConvert NSString:request[@"appVersion"]];
    [[PlugPag sharedInstance] plugPagAppIdentification:appName withVersion:appVersion];
    
    PlugPagDevice *device = [PlugPagDevice new];
    NSString *readerAddress = [RCTConvert NSString:request[@"readerAddress"]];
    device.mPeripheralName = readerAddress;
    PlugPagTransactionResult *ret = [[PlugPag sharedInstance] setInitBTConnection:device];
    
    if (ret.mResult == RET_OK) {
        NSString *total = [RCTConvert NSString:request[@"amount"]];
        NSString *totalAmount = [[total componentsSeparatedByCharactersInSet:
                                  [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                                 componentsJoinedByString:@""];
        
        NSUInteger *paymentType = [RCTConvert NSUInteger:[RCTConvert NSNumber:request[@"paymentType"]]];
        NSUInteger *installments = [RCTConvert NSUInteger:[RCTConvert NSNumber:request[@"installments"]]];
        InstallmentType installmentType = A_VISTA;
        if (installments > 0) {
            installmentType = PARC_VENDEDOR;
        }
        NSString *checkoutCode = [RCTConvert NSString:request[@"code"]];
        
        
        PlugPagPaymentData *data = [PlugPagPaymentData new];
        data.mType = paymentType;
        data.mAmount = [totalAmount intValue];
        data.mInstallmentType = installmentType;
        data.mInstallment = installments;
        data.mUserReference = checkoutCode;
        
        PlugPagTransactionResult *result = [[PlugPag sharedInstance] doPayment:data];
        if (result.mResult == RET_OK) {
            resolve(@{@"success": @RET_OK});
        } else {
            NSString *errorCode = [NSString stringWithFormat:@"%d",ret.mResult];
            NSString *errorMsg = [NSString stringWithFormat:@"Não foi possível conectar com o device %@.", readerAddress];
            reject(errorCode, errorMsg, nil);
        }
    } else {
        NSString *errorCode = [NSString stringWithFormat:@"%d",ret.mResult];
        NSString *errorMsg = [NSString stringWithFormat:@"Não foi possível conectar com o device %@.", readerAddress];
        reject(errorCode, errorMsg, nil);
    }
}

RCT_EXPORT_MODULE();

@end
