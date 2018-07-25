
#import "RNPlugpag.h"

@implementation RCTConvert (PlugPagPaymentType)

RCT_ENUM_CONVERTER(PaymentMethod, (
                                       @{@"CREDIT"  : @(CREDIT),
                                         @"DEBIT"   : @(DEBIT),
                                         @"VOUCHER" : @(VOUCHER)
                                         }), CREDIT, integerValue);

@end

@implementation RCTConvert (PlugPagInstallmentType)

RCT_ENUM_CONVERTER(InstallmentType, (
                                        @{@"A_VISTA" : @(A_VISTA),
                                          @"PARC_VENDEDOR"    : @(PARC_VENDEDOR)
                                      }), A_VISTA, integerValue);

@end

@implementation RNPlugpag

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

- (NSDictionary *)constantsToExport
{
    return @{ @"CREDIT": @(CREDIT),
              @"DEBIT": @(DEBIT),
              @"VOUCHER": @(VOUCHER),
              @"A_VISTA" : @(A_VISTA),
              @"PARC_VENDEDOR" : @(PARC_VENDEDOR)};
}

RCT_EXPORT_METHOD(authenticate:(NSDictionary *)request resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    NSString *appName = [RCTConvert NSString:request[@"appName"]];
    NSString *appVersion = [RCTConvert NSString:request[@"appVersion"]];
    [[PlugPag sharedInstance] plugPagAppIdentification:appName withVersion:appVersion];
    BOOL isAuthenticated = [[PlugPag sharedInstance] isAuthenticated];
    
    if (isAuthenticated == NO) {
        UIViewController *rootViewController = UIApplication.sharedApplication.delegate.window.rootViewController;
        [[PlugPag sharedInstance] requestAuthentication:rootViewController];
    }
}

RCT_EXPORT_METHOD(pairWithDevice:(NSDictionary *)request resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    UIViewController *rootViewController = UIApplication.sharedApplication.delegate.window.rootViewController;
    
    NSString *appName = [RCTConvert NSString:request[@"appName"]];
    NSString *appVersion = [RCTConvert NSString:request[@"appVersion"]];
    [[PlugPag sharedInstance] plugPagAppIdentification:appName withVersion:appVersion];
    [[PlugPag sharedInstance] setDelegate:self];
    
    NSString *readerAddress = [RCTConvert NSString:request[@"readerAddress"]];
    PlugPagDevice *device = [PlugPagDevice new];
    device.mPeripheralName = readerAddress;
    device.mType = TYPE_PINPAD;
    
    // tentando parear com o dispositivo
    [[PlugPag sharedInstance] pairPeripheral:device];
    PlugPagTransactionResult *ret = [[PlugPag sharedInstance] setInitBTConnection:device];
    resolve(@{@"success": @YES});
}

RCT_EXPORT_METHOD(checkout:(NSDictionary *)request resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    UIViewController *rootViewController = UIApplication.sharedApplication.delegate.window.rootViewController;
    [[PlugPag sharedInstance] setDelegate:rootViewController];
    
    NSString *appName = [RCTConvert NSString:request[@"appName"]];
    NSString *appVersion = [RCTConvert NSString:request[@"appVersion"]];
    [[PlugPag sharedInstance] plugPagAppIdentification:appName withVersion:appVersion];
    
    NSString *readerAddress = [RCTConvert NSString:request[@"readerAddress"]];
    
    NSString *total = [RCTConvert NSString:request[@"totalAmount"]];
    NSString *totalAmount = [[total componentsSeparatedByCharactersInSet:
                             [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                            componentsJoinedByString:@""];
    NSUInteger *paymentType = [RCTConvert PaymentMethod:request[@"paymentType"]];
    NSUInteger *installmentType = [RCTConvert InstallmentType:request[@"installmentType"]];
    NSUInteger *installments = [RCTConvert NSUInteger:[RCTConvert NSNumber:request[@"installments"]]];
    NSString *checkoutCode = [RCTConvert NSString:request[@"checkoutCode"]];
    
    PlugPagDevice *device = [PlugPagDevice new];
//    device.mPeripheralName = readerAddress;
    device.mPeripheralName = @"PAX-7C119559";
    device.mType = 0;
    
    // tentando parear com o dispositivo
    [[PlugPag sharedInstance] pairPeripheral:device];
    PlugPagTransactionResult *ret = [[PlugPag sharedInstance] setInitBTConnection:device];
    
    if (ret.mResult == RET_OK) {
        resolve(@{@"success": @RET_OK});
//        NSString *value = totalAmount;
//        PlugPagPaymentData *data = [PlugPagPaymentData new];
//        data.mType = paymentType;
//        data.mAmount = [value intValue];
//        data.mInstallmentType = installmentType;
//        data.mInstallment = installments;
//        data.mUserReference = checkoutCode;
//
//        PlugPagTransactionResult *result = [[PlugPag sharedInstance] doPayment:data];
//        if (result.mResult == RET_OK) {
//            resolve(@{@"success": @RET_OK});
//        } else {
//            NSString *errorCode = [NSString stringWithFormat:@"%d",result.mResult];
//            NSString *errorMsg = [NSString stringWithFormat:@"Não foi possível processar o pagamento com o device. Motivo: %@", result.mMessage];
//            reject(errorCode, errorMsg, nil);
//        }
    } else {
        NSString *errorCode = [NSString stringWithFormat:@"%d",ret.mResult];
        NSString *errorMsg = [NSString stringWithFormat:@"Não foi possível conectar com o device %@.", readerAddress];
        reject(errorCode, errorMsg, nil);
    }
}
RCT_EXPORT_MODULE()

@end
  
