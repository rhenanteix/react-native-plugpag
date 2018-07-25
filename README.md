# react-native-plugpag  
  
## Getting started  
  
`$ npm install react-native-plugpag --save`  
  
### Mostly automatic installation  
  
`$ react-native link react-native-plugpag`  
  
### Manual installation  
  
  
#### iOS  
  
1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`  
2. Go to `node_modules` ➜ `react-native-plugpag` and add `RNPlugpag.xcodeproj`  
3. In XCode, in the project navigator, select your project. Add `libRNPlugpag.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`  
4. Run your project (`Cmd+R`)<  
  
#### Android  
  
1. Open up `android/app/src/main/java/[...]/MainActivity.java`  
  - Add `import com.nextar.rn.plugpag.RNPlugpagPackage;` to the imports at the top of the file  
  - Add `new RNPlugpagPackage()` to the list returned by the `getPackages()` method  
2. Append the following lines to `android/settings.gradle`:  
   ```  
   include ':react-native-plugpag'  
   project(':react-native-plugpag').projectDir = new File(rootProject.projectDir,     '../node_modules/react-native-plugpag/android')  
   ```  
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:  
   ```  
      compile project(':react-native-plugpag')  
   ```  
  
# USING

  ```javascript  
import { RNPlugPag } from 'react-native-plugpag';  
```

## CONSTANTS  
### PAYMENT TYPES
**RNPlugPag.PAYMENT_CREDIT** - Set the payment as CREDIT.
**RNPlugPag.PAYMENT_DEBIT** - Set the payment as DEBIT.
**RNPlugPag.PAYMENT_VOUCHER** - Set the payment as VOUCHER.
### INSTALLMENTS TYPES
**RNPlugPag.INSTALLMENT_TYPE_A_VISTA** - Set the installment type as AT SIGHT (or A VISTA if you are brazilian) :)
**RNPlugPag.INSTALLMENT_TYPE_PARC_VENDEDOR** - Set the installment type as PARCELADO (please, help me to translate this).

## METHODS
**RNPlugPag.setAppInfo(appName, appVersion)** - Will set the app informations. (required)
**RNPlugPag.setDeviceInfo(deviceName | deviceMac)** - Will set PagSeguro device name or mac address. 
**RNPlugPag.isAuthenticated** - Will return a promise indicating if the reader is authenticated or not.
**RNPlugPag.requestAuthentication** - Will open PagSeguro authentication login.
**RNPlugPag.checkout(request)** - Will start the checkout process and returns a promise. The parameter **request** expects these format:
```javascript 
{
	paymentType: RNPlugPag.PAYMENT_DEBIT,  
	installments: 1,  
	code: 'SELL_CODE',  
	amount: '10000',
}
```

## EXAMPLE

#1 - Checkout R$ 100,00 using DEBIT CARD:
```javascript
import { RNPlugPag } from 'react-native-plugpag';

class MyPaymentClass {
	myPaymentMethod() {
		RNPlugPag.setAppInfo('MyApp', '1.0.0');
		RNPlugPag.setDeviceInfo('W-999999');

		RNPlugPag.isAuthenticated().then((result) => {
			if (result.isAuthenticated) {
				const request = {  
				  paymentType: RNPlugPag.PAYMENT_DEBIT,  
				  installments: 1,  
				  code: 'RNPlugPag',  
				  amount: '100,00',  
				};  
				RNPlugPag.checkout(request).then(checkoutResult => {  
				  console.log('result', checkoutResult);  
				}).catch(error => {  
				  console.log('error', error);  
				});
			}
		});
	}
}
```

#2 - Invoking authentication window:
```javascript
import { RNPlugPag } from 'react-native-plugpag';

class MyPaymentClass {
	myPaymentMethod() {
		RNPlugPag.setAppInfo('MyApp', '1.0.0');
		RNPlugPag.requestAuthentication();
	}
}
```

#3 - Checkout R$ 123,45 using CREDIT CARD with 5 installments:
```javascript
import { RNPlugPag } from 'react-native-plugpag';

class MyPaymentClass {
	myPaymentMethod() {
		RNPlugPag.setAppInfo('MyApp', '1.0.0');
		RNPlugPag.setDeviceInfo('W-999999');

		RNPlugPag.isAuthenticated().then((result) => {
			if (result.isAuthenticated) {
				const request = {  
				  paymentType: RNPlugPag.PAYMENT_CREDIT,  
				  installments: 5,  
				  code: 'RNPlugPag',  
				  amount: '123,45',  
				};  
				RNPlugPag.checkout(request).then(checkoutResult => {  
				  console.log('result', checkoutResult);  
				}).catch(error => {  
				  console.log('error', error);  
				});
			}
		});
	}
}
```





**Feel free to contribute :)**