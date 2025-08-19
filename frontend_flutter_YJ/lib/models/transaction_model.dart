// 거래 내역 정보를 담을 클래스
enum TransactionType { deposit, withdrawal }

class Transaction {
  final String date;
  final String time;
  final String description;
  final int amount;
  final int balanceAfter;
  final TransactionType type;

  Transaction({
    required this.date,
    required this.time,
    required this.description,
    required this.amount,
    required this.balanceAfter,
    required this.type,
  });
}