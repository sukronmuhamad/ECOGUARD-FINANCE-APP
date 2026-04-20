class Transaction {
  final int? id;
  final String title;
  final double amount;
  final String type;
  final String category;

  Transaction({
    this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
  });

  // Untuk mengubah JSON dari API menjadi Object Flutter
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      title: json['title'],
      amount: json['amount'].toDouble(),
      type: json['type'],
      category: json['category'],
    );
  }

  // Untuk mengubah Object Flutter menjadi JSON untuk dikirim ke API
  Map<String, dynamic> toJson() => {
    'title': title,
    'amount': amount,
    'type': type,
    'category': category,
  };
}
