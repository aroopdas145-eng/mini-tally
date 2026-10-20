import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = await initDatabase();
  runApp(TallyPrimeApp(db: db));
}

// ---------------- DATABASE SETUP ----------------
Future<Database> initDatabase() async {
  final dbPath = await getDatabasesPath();
  final path = p.join(dbPath, 'tally_gold_v2.db');

  return await openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE ledgers (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          type TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE transactions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          ledger_id INTEGER,
          type TEXT NOT NULL,
          amount REAL NOT NULL,
          note TEXT,
          date TEXT NOT NULL,
          FOREIGN KEY (ledger_id) REFERENCES ledgers (id)
        )
      ''');

      await db.insert('ledgers', {'name': 'Cash in Hand', 'type': 'Cash-in-hand'});
      await db.insert('ledgers', {'name': 'State Bank of India', 'type': 'Bank Accounts'});
      await db.insert('ledgers', {'name': 'Sales Account', 'type': 'Sales Accounts'});
      await db.insert('ledgers', {'name': 'Purchase Account', 'type': 'Purchase Accounts'});
      await db.insert('ledgers', {'name': 'General Expenses', 'type': 'Indirect Expenses'});
    },
  );
}

// ---------------- APP THEME ----------------
class TallyPrimeApp extends StatelessWidget {
  final Database db;
  const TallyPrimeApp({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tally Mobile Prime',
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF4F7FB),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D3B66),
          primary: const Color(0xFF0D3B66),
          secondary: const Color(0xFFF4D06F),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A2E50),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      home: GatewayOfTallyScreen(db: db),
    );
  }
}

// ---------------- GATEWAY OF TALLY ----------------
class GatewayOfTallyScreen extends StatefulWidget {
  final Database db;
  const GatewayOfTallyScreen({super.key, required this.db});

  @override
  State<GatewayOfTallyScreen> createState() => _GatewayOfTallyScreenState();
}

class _GatewayOfTallyScreenState extends State<GatewayOfTallyScreen> {
  double _totalDebit = 0.0;
  double _totalCredit = 0.0;
  int _voucherCount = 0;

  @override
  void initState() {
    super.initState();
    _refreshStats();
  }

  Future<void> _refreshStats() async {
    final entries = await widget.db.rawQuery('SELECT type, amount FROM transactions');
    double dr = 0.0;
    double cr = 0.0;
    for (var r in entries) {
      final amt = (r['amount'] as num).toDouble();
      if (r['type'] == 'DR') {
        dr += amt;
      } else {
        cr += amt;
      }
    }
    setState(() {
      _totalDebit = dr;
      _totalCredit = cr;
      _voucherCount = entries.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF4D06F),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Tally',
                style: TextStyle(
                  color: Color(0xFF0A2E50),
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text('Gateway of Tally', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: const Color(0xFF1E4870),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CURRENT COMPANY', style: TextStyle(fontSize: 10, color: Color(0xFFF4D06F), fontWeight: FontWeight.bold)),
                      Text('My Business Khata', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('STATUS', style: TextStyle(fontSize: 10, color: Color(0xFFF4D06F), fontWeight: FontWeight.bold)),
                      Text('Offline Safe', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF81C784)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.arrow_downward, color: Color(0xFF2E7D32), size: 18),
                              SizedBox(width: 4),
                              Text('Total In (Dr)', style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('₹${_totalDebit.toStringAsFixed(1)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1B5E20))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFB74D)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.arrow_upward, color: Color(0xFFE65100), size: 18),
                              SizedBox(width: 4),
                              Text('Total Out (Cr)', style: TextStyle(color: Color(0xFFE65100), fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('₹${_totalCredit.toStringAsFixed(1)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFFBF360C))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('MASTERS & TRANSACTIONS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF5A6E85), letterSpacing: 1)),
                  const SizedBox(height: 8),
                  _buildMenuCard(
                    title: 'Vouchers (Entry)',
                    subtitle: 'Sales, Purchase, Payment, Receipt',
                    icon: Icons.receipt_long,
                    badgeColor: const Color(0xFFE3F2FD),
                    iconColor: const Color(0xFF1565C0),
                    onTap: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (context) => VoucherEntryScreen(db: widget.db)));
                      _refreshStats();
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildMenuCard(
                    title: 'Day Book (Transactions)',
                    subtitle: '$_voucherCount total entries recorded',
                    icon: Icons.history_edu,
                    badgeColor: const Color(0xFFEDE7F6),
                    iconColor: const Color(0xFF673AB7),
                    onTap: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (context) => DayBookScreen(db: widget.db)));
                      _refreshStats();
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildMenuCard(
                    title: 'Create Ledger (Party)',
                    subtitle: 'Customer, Supplier, Expenses',
                    icon: Icons.person_add_alt_1,
                    badgeColor: const Color(0xFFFFF8E1),
                    iconColor: const Color(0xFFF57F17),
                    onTap: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (context) => CreateLedgerScreen(db: widget.db)));
                      _refreshStats();
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text('REPORTS & STATEMENTS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF5A6E85), letterSpacing: 1)),
                  const SizedBox(height: 8),
                  _buildMenuCard(
                    title: 'Accounts & Khata List',
                    subtitle: 'Party-wise balance summary',
                    icon: Icons.account_balance_wallet,
                    badgeColor: const Color(0xFFE0F2F1),
                    iconColor: const Color(0xFF00796B),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => LedgerDirectoryScreen(db: widget.db)));
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildMenuCard(
                    title: 'Profit & Loss / Trial Balance',
                    subtitle: 'Real-time financial statement',
                    icon: Icons.pie_chart_outline,
                    badgeColor: const Color(0xFFFCE4EC),
                    iconColor: const Color(0xFFC2185B),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => TallyReportsScreen(db: widget.db)));
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color badgeColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}

// ---------------- 1. VOUCHER ENTRY SCREEN ----------------
class VoucherEntryScreen extends StatefulWidget {
  final Database db;
  const VoucherEntryScreen({super.key, required this.db});

  @override
  State<VoucherEntryScreen> createState() => _VoucherEntryScreenState();
}

class _VoucherEntryScreenState extends State<VoucherEntryScreen> {
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String _entryType = 'DR';
  int? _selectedLedgerId;
  List<Map<String, dynamic>> _ledgers = [];

  @override
  void initState() {
    super.initState();
    _fetchLedgers();
  }

  Future<void> _fetchLedgers() async {
    final list = await widget.db.query('ledgers', orderBy: 'name ASC');
    setState(() {
      _ledgers = list;
      if (list.isNotEmpty) _selectedLedgerId = list.first['id'] as int;
    });
  }

  Future<void> _saveVoucher() async {
    final amt = double.tryParse(_amountCtrl.text);
    if (amt == null || amt <= 0 || _selectedLedgerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sahi amount aur account chuniye')));
      return;
    }
    final today = DateTime.now().toString().split(' ')[0];
    await widget.db.insert('transactions', {
      'ledger_id': _selectedLedgerId,
      'type': _entryType,
      'amount': amt,
      'note': _noteCtrl.text.trim().isEmpty ? 'Voucher' : _noteCtrl.text.trim(),
      'date': today,
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Voucher Saved!'), backgroundColor: Colors.green));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accounting Voucher Entry')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _entryType = 'DR'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _entryType == 'DR' ? const Color(0xFF2E7D32) : const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          'DEBIT (DR)',
                          style: TextStyle(color: _entryType == 'DR' ? Colors.white : const Color(0xFF2E7D32), fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _entryType = 'CR'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _entryType == 'CR' ? const Color(0xFFC62828) : const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          'CREDIT (CR)',
                          style: TextStyle(color: _entryType == 'CR' ? Colors.white : const Color(0xFFC62828), fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<int>(
              value: _selectedLedgerId,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                labelText: 'Account Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              items: _ledgers.map((l) => DropdownMenuItem<int>(value: l['id'] as int, child: Text('${l['name']} (${l['type']})'))).toList(),
              onChanged: (v) => setState(() => _selectedLedgerId = v),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0D3B66)),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                labelText: 'Amount (₹)',
                prefixText: '₹ ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteCtrl,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                labelText: 'Narration / Remark',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 26),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0A2E50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: _saveVoucher,
                child: const Text('SAVE VOUCHER', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- 2. DAY BOOK SCREEN ----------------
class DayBookScreen extends StatefulWidget {
  final Database db;
  const DayBookScreen({super.key, required this.db});

  @override
  State<DayBookScreen> createState() => _DayBookScreenState();
}

class _DayBookScreenState extends State<DayBookScreen> {
  List<Map<String, dynamic>> _list = [];

  @override
  void initState() {
    super.initState();
    _loadDayBook();
  }

  Future<void> _loadDayBook() async {
    final res = await widget.db.rawQuery('''
      SELECT t.id, t.type, t.amount, t.note, t.date, l.name as ledger_name 
      FROM transactions t 
      JOIN ledgers l ON t.ledger_id = l.id 
      
