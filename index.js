import { NativeModules, Platform } from 'react-native';

const { RNPlugpag } = NativeModules;

export const RNPlugPag = {
  appName: '',
  appVersion: '',
  readerAddress: '',

  PAYMENT_CREDIT: RNPlugpag.PAYMENT_CREDIT,
  PAYMENT_DEBIT: RNPlugpag.PAYMENT_DEBIT,
  PAYMENT_VOUCHER: RNPlugpag.PAYMENT_VOUCHER,

  INSTALLMENT_TYPE_A_VISTA: RNPlugpag.INSTALLMENT_TYPE_A_VISTA,
  INSTALLMENT_TYPE_PARC_VENDEDOR: RNPlugpag.INSTALLMENT_TYPE_PARC_VENDEDOR,

  setAppInfo(appName = '', appVersion = '') {
    this.appName = appName;
    this.appVersion = appVersion;
  },

  setDeviceInfo(readerAddress) {
    if (Platform.OS === 'ios' && readerAddress.includes('PAX')) {
      console.error('Esta biblioteca ainda não suporta a MINIZINHA no iOS! :(');
      return;
    }

    this.readerAddress = readerAddress;
  },

  isAuthenticated() {
    if (!this.appName || !this.appVersion) {
      throw new Error('You must set appName and appVersion before call isAuthenticated method.');
    }

    return RNPlugpag.isAuthenticated({ appName: this.appName, appVersion: this.appVersion });
  },

  /**
   * Will open PagSeguro Authentication screen
   */
  requestAuthentication() {
    if (!this.appName || !this.appVersion) {
      throw new Error('You must set appName and appVersion before call requestAuthentication method.');
    }

    RNPlugpag.requestAuthentication({ appName: this.appName, appVersion: this.appVersion });
  },

  checkout(request) {
    if (!this.appName || !this.appVersion || !this.readerAddress) {
      throw new Error('You must set appName, appVersion and readerAddress before call checkout method.');
    }

    return RNPlugpag.checkout({ ...request, appName: this.appName, appVersion: this.appVersion, readerAddress: this.readerAddress, });
  },
};