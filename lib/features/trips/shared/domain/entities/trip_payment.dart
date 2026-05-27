/// Payment method keys stored on [TripEntity.paymentMethodKey].
const paymentMethodCashKey = 'payment_cash';
const paymentMethodCardKey = 'payment_card';

bool tripUsesWallet(String? paymentMethodKey) {
  return paymentMethodKey == null || paymentMethodKey == paymentMethodCardKey;
}
