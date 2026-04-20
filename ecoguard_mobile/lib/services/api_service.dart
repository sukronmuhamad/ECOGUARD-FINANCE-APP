import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction_model.dart';

class ApiService {
  // Ganti localhost ke 10.0.2.2 untuk Emulator Android
  static const String baseUrl = "http://localhost:3000";

  Future<List<Transaction>> getTransactions() async {
    final response = await http.get(Uri.parse('$baseUrl/transactions'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Transaction.fromJson(data)).toList();
    } else {
      throw Exception('Gagal mengambil data');
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    await http.post(
      Uri.parse('$baseUrl/transactions'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(transaction.toJson()),
    );
  }

  Future<void> deleteTransaction(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/transactions/$id'));
    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus data');
    }
  }
}
