/// Simple ParsedTransaction class for SMS analysis
class ParsedTransaction {
  final String id;
  final String description;
  final double amount;
  final String category;
  final DateTime date;
  final String rawText;
  final String type; // 'debit' or 'credit'
  final String sender;

  ParsedTransaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
    required this.rawText,
    required this.type,
    required this.sender,
  });
}
