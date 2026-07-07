class TransactionModel {
  final int? id;
  final int categoryId;
  final String type; // 'income' atau 'expense'
  final double amount;
  final String? note;
  final DateTime transactionDate;
  final String? receiptPhoto;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Field tambahan hasil JOIN, tidak disimpan di tabel transactions
  final String? categoryName;
  final String? categoryIcon;
  final String? categoryColor;

  TransactionModel({
    this.id,
    required this.categoryId,
    required this.type,
    required this.amount,
    this.note,
    required this.transactionDate,
    this.receiptPhoto,
    DateTime? createdAt,
    this.updatedAt,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'type': type,
      'amount': amount,
      'note': note,
      'transaction_date':
          '${transactionDate.year}-${transactionDate.month.toString().padLeft(2, '0')}-${transactionDate.day.toString().padLeft(2, '0')}',
      'receipt_photo': receiptPhoto,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      categoryId: map['category_id'] as int,
      type: map['type'] as String,
      amount: (map['amount'] as num).toDouble(),
      note: map['note'] as String?,
      transactionDate: DateTime.parse(map['transaction_date'] as String),
      receiptPhoto: map['receipt_photo'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      categoryName: map['category_name'] as String?,
      categoryIcon: map['icon'] as String?,
      categoryColor: map['color'] as String?,
    );
  }
}