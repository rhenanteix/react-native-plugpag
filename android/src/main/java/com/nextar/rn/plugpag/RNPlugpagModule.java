
package com.nextar.rn.plugpag;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;

import br.com.uol.pagseguro.plugpag.PlugPag;
import br.com.uol.pagseguro.plugpag.PlugPagAppIdentification;
import br.com.uol.pagseguro.plugpag.PlugPagDevice;
import br.com.uol.pagseguro.plugpag.PlugPagPaymentData;
import br.com.uol.pagseguro.plugpag.PlugPagTransactionResult;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

public class RNPlugpagModule extends ReactContextBaseJavaModule {

  private final ReactApplicationContext reactContext;

  public RNPlugpagModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
  }

  @Override
  public String getName() {
    return "RNPlugpag";
  }

  @Override
  public Map<String, Object> getConstants() {
    final Map<String, Object> constants = new HashMap<>();
    constants.put("PAYMENT_CREDIT", PlugPag.TYPE_CREDITO);
    constants.put("PAYMENT_DEBIT", PlugPag.TYPE_DEBITO);
    constants.put("PAYMENT_VOUCHER", PlugPag.TYPE_VOUCHER);
    constants.put("INSTALLMENT_TYPE_A_VISTA", PlugPag.INSTALLMENT_TYPE_A_VISTA);
    constants.put("INSTALLMENT_TYPE_PARC_VENDEDOR", PlugPag.INSTALLMENT_TYPE_PARC_VENDEDOR);
    return constants;
  }

  @ReactMethod
  public void isAuthenticated(ReadableMap request, Promise promise) {
    String appName = request.getString("appName");
    String appVersion = request.getString("appVersion");

    PlugPagAppIdentification appIdentification = new PlugPagAppIdentification(appName, appVersion);
    final PlugPag plugpag = new PlugPag(reactContext, appIdentification);

    ExecutorService executor = Executors.newSingleThreadExecutor();
    Callable<Boolean> callable = new Callable<Boolean>() {
      @Override
      public Boolean call() {
        return plugpag.isAuthenticated();
      }
    };
    Future<Boolean> future = executor.submit(callable);
    executor.shutdown();

    final WritableMap map = Arguments.createMap();
    try {
      map.putBoolean("isAuthenticated", future.get());
      promise.resolve(map);
    } catch (InterruptedException e) {
      promise.reject("000", e.getMessage());
    } catch (ExecutionException e) {
      promise.reject("000", e.getMessage());
    }
  }

  @ReactMethod
  public void requestAuthentication(ReadableMap request) {
    String appName = request.getString("appName");
    String appVersion = request.getString("appVersion");

    PlugPagAppIdentification appIdentification = new PlugPagAppIdentification(appName, appVersion);
    final PlugPag plugpag = new PlugPag(reactContext, appIdentification);

    ExecutorService executor = Executors.newSingleThreadExecutor();
    Callable<Integer> callable = new Callable<Integer>() {
      @Override
      public Integer call() {
        return plugpag.requestAuthentication(getCurrentActivity());
      }
    };
    executor.submit(callable);
    executor.shutdown();
  }

  @ReactMethod
  public void checkout(ReadableMap request, Promise promise) throws ExecutionException, InterruptedException {
    String appName = request.getString("appName");
    String appVersion = request.getString("appVersion");
    String readerAddress = request.getString("readerAddress");

    PlugPagAppIdentification appIdentification = new PlugPagAppIdentification(appName, appVersion);
    final PlugPag plugpag = new PlugPag(reactContext, appIdentification);
    final PlugPagDevice device = new PlugPagDevice(readerAddress);

    int paymentType = request.getInt("paymentType");
    int installments = request.getInt("installments");
    int installmentType = PlugPag.INSTALLMENT_TYPE_A_VISTA;
    String userReference = request.getString("code");
    String amount = request.getString("amount").replace(".", "").replace(",", "");

    if (installments > 1) {
      installmentType = PlugPag.INSTALLMENT_TYPE_PARC_VENDEDOR;
    }

    ExecutorService connectionExecutor = Executors.newSingleThreadExecutor();
    Callable<PlugPagTransactionResult> connectionCallable = new Callable<PlugPagTransactionResult>() {
      @Override
      public PlugPagTransactionResult call() {
        return plugpag.initBTConnection(device);
      }
    };
    Future<PlugPagTransactionResult> btConnection = connectionExecutor.submit(connectionCallable);
    connectionExecutor.shutdown();

    // final strings for success or fail :)
    String resultCode;
    String resultMessage;

    if (btConnection.get() != null && btConnection.get().getResult() == PlugPag.RET_OK) {
      final PlugPagPaymentData paymentData = new PlugPagPaymentData(
              paymentType,
              Integer.valueOf(amount),
              installmentType,
              installments,
              userReference);
      ExecutorService paymentExecutor = Executors.newSingleThreadExecutor();
      Callable<PlugPagTransactionResult> paymentCallable = new Callable<PlugPagTransactionResult>() {
        @Override
        public PlugPagTransactionResult call() {
          return plugpag.doPayment(paymentData);
        }
      };

      Future<PlugPagTransactionResult> transactionResult = paymentExecutor.submit(paymentCallable);
//      paymentExecutor.shutdown();

      if (transactionResult.get() != null && transactionResult.get().getResult() == PlugPag.RET_OK) {
        WritableMap map = Arguments.createMap();
        map.putInt("code", transactionResult.get().getResult());
        map.putString("msg", transactionResult.get().getMessage());
        map.putString("transactionCode", transactionResult.get().getTransactionCode());
        map.putString("transactionId", transactionResult.get().getTransactionId());
        map.putString("cardType", transactionResult.get().getCardBrand());
        map.putString("cardLast4Digits", transactionResult.get().getBin());

        promise.resolve(map);
      } else {
        resultCode = "0";
        resultMessage = "Não foi possível processar o pagamento.";
        if (transactionResult.get() != null) {
          resultCode = String.valueOf(transactionResult.get().getResult());
          resultMessage = transactionResult.get().getMessage();
        }
        promise.reject(resultCode, resultMessage);
      }
    } else {
      resultCode = "0";
      resultMessage = "Não foi possível conectar ao device.";
      if (btConnection.get() != null) {
        resultCode = String.valueOf(btConnection.get().getResult());
        resultMessage = btConnection.get().getMessage();
      }
      promise.reject(resultCode, resultMessage);
    }
  }
}