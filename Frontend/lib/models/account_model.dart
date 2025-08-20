// 계좌 정보를 담을 클래스
class Account {
  final String bankName;
  final String accountName;
  final String accountNumber;
  final int balance;

  final String productName;
  final String openingDate;
  final String maturityDate;
  final double interestRate;

  Account({
    required this.bankName,
    required this.accountName,
    required this.accountNumber,
    required this.balance,

    required this.productName,
    required this.openingDate,
    required this.maturityDate,
    required this.interestRate,
  });
}