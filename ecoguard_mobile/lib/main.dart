import 'package:flutter/material.dart';
import 'models/transaction_model.dart';
import 'services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const EcoGuardApp());
}

class EcoGuardApp extends StatelessWidget {
  const EcoGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EcoGuard Smart Finance',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const TransactionScreen(),
    );
  }
}

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Transaction>> transactions;

  // Controller & State
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  final List<String> _categories = [
    'Makan & Minum',
    'Transportasi',
    'Belanja',
    'Tagihan',
    'Gaji',
    'Kesehatan',
    'Lainnya',
  ];

  String _selectedCategory = 'Makan & Minum';
  String _selectedType = 'expense';
  String _currentFilter = 'Semua';
  String _searchQuery = ''; // Baru: State pencarian

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      transactions = apiService.getTransactions();
    });
  }

  // --- LOGIKA PIE CHART (Sesuai kode Anda) ---
  Widget _buildPieChart(List<Transaction> allTransactions) {
    final expenses = allTransactions.where((t) => t.type == 'expense').toList();
    if (expenses.isEmpty) return const SizedBox();

    Map<String, double> dataMap = {};
    for (var t in expenses) {
      dataMap[t.category] = (dataMap[t.category] ?? 0) + t.amount;
    }

    List<PieChartSectionData> sections = [];
    int colorIndex = 0;
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.cyan,
      Colors.amber,
    ];

    dataMap.forEach((category, amount) {
      sections.add(
        PieChartSectionData(
          value: amount,
          title: '',
          radius: 40,
          color: colors[colorIndex % colors.length],
        ),
      );
      colorIndex++;
    });

    return Container(
      height: 150,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: PieChart(
        PieChartData(
          sections: sections,
          centerSpaceRadius: 40,
          sectionsSpace: 2,
        ),
      ),
    );
  }

  IconData _getIconByCategory(String category) {
    switch (category) {
      case 'Makan & Minum':
        return Icons.restaurant;
      case 'Transportasi':
        return Icons.directions_car;
      case 'Belanja':
        return Icons.shopping_bag;
      case 'Tagihan':
        return Icons.bolt;
      case 'Gaji':
        return Icons.payments;
      case 'Kesehatan':
        return Icons.medical_services;
      default:
        return Icons.category;
    }
  }

  // --- MODAL TAMBAH DATA (Sesuai kode Anda) ---
  void _showAddTransactionDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Tambah Transaksi Baru",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Judul (Contoh: Beli Kopi)",
                ),
              ),
              TextField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: "Jumlah (Rp)",
                  hintText: "Contoh: 50000",
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: false,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: "Pilih Kategori",
                  border: OutlineInputBorder(),
                ),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) =>
                    setModalState(() => _selectedCategory = val!),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ChoiceChip(
                    label: const Text("Pemasukan"),
                    selected: _selectedType == 'income',
                    onSelected: (val) =>
                        setModalState(() => _selectedType = 'income'),
                  ),
                  ChoiceChip(
                    label: const Text("Pengeluaran"),
                    selected: _selectedType == 'expense',
                    selectedColor: Colors.red.shade100,
                    onSelected: (val) =>
                        setModalState(() => _selectedType = 'expense'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final amountValue =
                        double.tryParse(_amountController.text) ?? 0;
                    if (_titleController.text.trim().isEmpty ||
                        amountValue <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Judul harus diisi dan jumlah harus lebih dari 0!",
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    final newTx = Transaction(
                      title: _titleController.text,
                      amount: amountValue,
                      type: _selectedType,
                      category: _selectedCategory,
                    );
                    await apiService.addTransaction(newTx);
                    _titleController.clear();
                    _amountController.clear();
                    if (!mounted) return;
                    Navigator.pop(context);
                    _refreshData();
                  },
                  child: const Text("Simpan Transaksi"),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryItem(String label, double amount, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: color, fontSize: 12)),
        Text(
          NumberFormat.currency(
            locale: 'id',
            symbol: 'Rp',
            decimalDigits: 0,
          ).format(amount),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _filterChip(String label) {
    return ActionChip(
      label: Text(label),
      backgroundColor: _currentFilter == label ? Colors.green.shade100 : null,
      onPressed: () => setState(() => _currentFilter = label),
    );
  }

  // Letakkan di dalam class _TransactionScreenState
  Widget _insightItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("EcoGuard Finance"),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Transaction>>(
        future: transactions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());

          final allData = snapshot.data ?? [];

          // Hitung Saldo
          double totalIncome = allData
              .where((t) => t.type == 'income')
              .fold(0, (sum, t) => sum + t.amount);
          double totalExpense = allData
              .where((t) => t.type == 'expense')
              .fold(0, (sum, t) => sum + t.amount);
          double balance = totalIncome - totalExpense;

          // --- LOGIKA FILTER DOUBLE (Kategori + Search) ---
          final filteredList = allData.where((t) {
            bool matchesCategory = true;
            if (_currentFilter == 'Pemasukan')
              matchesCategory = (t.type == 'income');
            if (_currentFilter == 'Pengeluaran')
              matchesCategory = (t.type == 'expense');

            bool matchesSearch =
                t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                t.category.toLowerCase().contains(_searchQuery.toLowerCase());

            return matchesCategory && matchesSearch;
          }).toList();

          // --- LOGIKA ANALITIK (Sisipkan di sini) ---
          Map<String, double> categoryMap = {};
          for (var t in allData.where((element) => element.type == 'expense')) {
            categoryMap[t.category] = (categoryMap[t.category] ?? 0) + t.amount;
          }

          String terboros = "N/A";
          double maxAmt = 0;
          categoryMap.forEach((cat, amt) {
            if (amt > maxAmt) {
              maxAmt = amt;
              terboros = cat;
            }
          });

          double rataRata = allData.isEmpty ? 0 : totalExpense / 30;
          double hematRatio = totalIncome > 0
              ? ((totalIncome - totalExpense) / totalIncome) * 100
              : 0;
          // --- SELESAI LOGIKA ---

          return Column(
            children: [
              // --- DASHBOARD (Sesuai kode Anda) ---
              Container(
                margin: const EdgeInsets.all(15),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.green, Colors.teal],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "Total Saldo Anda",
                      style: TextStyle(color: Colors.white70),
                    ),
                    Text(
                      NumberFormat.currency(
                        locale: 'id',
                        symbol: 'Rp ',
                        decimalDigits: 0,
                      ).format(balance),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                      ),
                    ),
                    _buildPieChart(allData),
                    const Divider(color: Colors.white24, height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _summaryItem("Income", totalIncome, Colors.white),
                        _summaryItem("Expense", totalExpense, Colors.white70),
                      ],
                    ),
                  ],
                ),
              ),

              // --- SEARCH BAR (Fitur Baru) ---
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 5,
                ),
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: "Cari transaksi atau kategori...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              // Sisipkan di bawah Search Bar (TextField)
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _insightItem(
                      Icons.trending_up,
                      "Terboros",
                      terboros,
                      Colors.orange,
                    ),
                    _insightItem(
                      Icons.speed,
                      "Rata-rata/Hari",
                      NumberFormat.currency(
                        locale: 'id',
                        symbol: 'Rp',
                        decimalDigits: 0,
                      ).format(rataRata),
                      Colors.blue,
                    ),
                    // Contoh logika warna dinamis untuk Saving Rate
                    _insightItem(
                      Icons.savings,
                      "Saving Rate",
                      "${hematRatio.toStringAsFixed(1)}%",
                      hematRatio < 0
                          ? Colors.red
                          : Colors
                                .green, // Merah jika minus, Hijau jika surplus
                    ),
                  ],
                ),
              ),

              // FILTER CHIPS
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _filterChip("Semua"),
                  const SizedBox(width: 8),
                  _filterChip("Pemasukan"),
                  const SizedBox(width: 8),
                  _filterChip("Pengeluaran"),
                ],
              ),

              // LIST TRANSAKSI
              Expanded(
                child: filteredList.isEmpty
                    ? const Center(child: Text("Tidak ada transaksi ditemukan"))
                    : ListView.builder(
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final tx = filteredList[index];
                          return Dismissible(
                            key: Key(tx.id.toString()),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              return await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Hapus Data?"),
                                  content: Text("Yakin hapus '${tx.title}'?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text("Batal"),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text(
                                        "Hapus",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            onDismissed: (direction) async {
                              await apiService.deleteTransaction(tx.id!);
                              _refreshData();
                            },
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: tx.type == 'income'
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                child: Icon(
                                  _getIconByCategory(tx.category),
                                  color: tx.type == 'income'
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              title: Text(
                                tx.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(tx.category),
                              trailing: Text(
                                NumberFormat.currency(
                                  locale: 'id',
                                  symbol: 'Rp ',
                                  decimalDigits: 0,
                                ).format(tx.amount),
                                style: TextStyle(
                                  color: tx.type == 'income'
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransactionDialog,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
