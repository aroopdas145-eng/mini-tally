import 'package:flutter/material.dart';

void main() {
  runApp(const TallyApp());
}

class TallyApp extends StatelessWidget {
  const TallyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tally Mobile',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF4F7FB),
        primaryColor: const Color(0xFF0D3B66),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A2E50),
          foregroundColor: Colors.white,
        ),
      ),
      home: const GatewayScreen(),
    );
  }
}

class GatewayScreen extends StatefulWidget {
  const GatewayScreen({super.key});

  @override
  State<GatewayScreen> createState() => _GatewayScreenState();
}

class _GatewayScreenState extends State<GatewayScreen> {
  final List<Map<String, dynamic>> _vouchers = [
    {'party': 'Cash in Hand', 'type': 'DR', 'amount': 15000.0, 'date': '2026-10-21'},
    {'party': 'Sales Account', 'type': 'CR', 'amount': 8500.0, 'date': '2026-10-21'},
  ];

  double get _totalDebit => _vouchers.where((e) => e['type'] == 'DR').fold(0.0, (s, e) => s + (e['amount'] as double));
  double get _totalCredit => _vouchers.where((e) => e['type'] == 'CR').fold(0.0, (s, e) => s + (e['amount'] as double));

  void _addVoucher(String party, String type, double amt) {
    setState(() {
      _vouchers.insert(0, {
        'party': party,
        'type': type,
        'amount': amt,
        'date': DateTime.now().toString().split(' ')[0],
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gateway of Tally')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF1E4870), borderRadius: BorderRadius.circular(10)),
            child: const Text('Tally Mobile Khata (Offline)', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total In (Dr)', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('₹${_totalDebit.toStringAsFixed(1)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Out (Cr)', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('₹${_totalCredit.toStringAsFixed(1)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0A2E50), padding: const EdgeInsets.symmetric(vertical: 14)),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('NEW VOUCHER ENTRY', style: TextStyle(color: Colors.white)),
            onPressed: () => _openEntryDialog(context),
          ),
          const SizedBox(height: 20),
          const Text('Recent Transactions (Day Book)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          ..._vouchers.map((v) => Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: v['type'] == 'DR' ? Colors.green.shade100 : Colors.red.shade100,
                child: Text(v['type'], style: TextStyle(color: v['type'] == 'DR' ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
              ),
              title: Text(v['party'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(v['date']),
              trailing: Text('₹${v['amount']}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: v['type'] == 'DR' ? Colors.green : Colors.red)),
            ),
          )),
        ],
      ),
    );
  }

  void _openEntryDialog(BuildContext context) {
    final partyCtrl = TextEditingController();
    final amtCtrl = TextEditingController();
    String selectedType = 'DR';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDState) => AlertDialog(
          title: const Text('Add Voucher'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: partyCtrl, decoration: const InputDecoration(labelText: 'Party / Ledger Name')),
              TextField(controller: amtCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount (₹)')),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ChoiceChip(label: const Text('Debit (In)'), selected: selectedType == 'DR', onSelected: (_) => setDState(() => selectedType = 'DR')),
                  ChoiceChip(label: const Text('Credit (Out)'), selected: selectedType == 'CR', onSelected: (_) => setDState(() => selectedType = 'CR')),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
            ElevatedButton(
              onPressed: () {
                final amt = double.tryParse(amtCtrl.text);
                if (partyCtrl.text.isNotEmpty && amt != null && amt > 0) {
                  _addVoucher(partyCtrl.text.trim(), selectedType, amt);
                  Navigator.pop(ctx);
                }
              },
              child: const Text('SAVE'),
            ),
          ],
        ),
      ),
    );
  }
}
.db.insert('transactions', {
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
      appBar: AppBar(title: const Text('New Voucher Entry')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: _entryType == 'DR' ? Colors.green : Colors.grey.shade300),
                    onPressed: () => setState(() => _entryType = 'DR'),
                    child: Text('DEBIT (DR)', style: TextStyle(color: _entryType == 'DR' ? Colors.white : Colors.black)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: _entryType == 'CR' ? Colors.red : Colors.grey.shade300),
                    onPressed: () => setState(() => _entryType = 'CR'),
                    child: Text('CREDIT (CR)', style: TextStyle(color: _entryType == 'CR' ? Colors.white : Colors.black)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _selectedLedgerId,
              decoration: const InputDecoration(labelText: 'Account Name', border: OutlineInputBorder()),
              items: _ledgers.map((l) => DropdownMenuItem<int>(value: l['id'] as int, child: Text('${l['name']} (${l['type']})'))).toList(),
              onChanged: (v) => setState(() => _selectedLedgerId = v),
            ),
            const SizedBox(height: 16),
            TextField(controller: _amountCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Amount (₹)', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(controller: _noteCtrl, decoration: const InputDecoration(labelText: 'Narration / Remark', border: OutlineInputBorder())),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0A2E50)),
                onPressed: _saveVoucher,
                child: const Text('SAVE VOUCHER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
    _load();
  }

  Future<void> _load() async {
    final res = await widget.db.rawQuery('SELECT t.id, t.type, t.amount, t.note, t.date, l.name as ledger_name FROM transactions t JOIN ledgers l ON t.ledger_id = l.id ORDER BY t.id DESC');
    setState(() => _list = res);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Day Book')),
      body: _list.isEmpty
          ? const Center(child: Text('Koi transaction nahi hai.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _list.length,
              itemBuilder: (context, idx) {
                final item = _list[idx];
                final isDr = item['type'] == 'DR';
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isDr ? Colors.green.shade100 : Colors.red.shade100,
                      child: Text(item['type'], style: TextStyle(color: isDr ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(item['ledger_name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${item['date']} • ${item['note']}'),
                    trailing: Text('₹${item['amount']}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDr ? Colors.green : Colors.red)),
                  ),
                );
              },
            ),
    );
  }
}

class CreateLedgerScreen extends StatefulWidget {
  final Database db;
  const CreateLedgerScreen({super.key, required this.db});
  @override
  State<CreateLedgerScreen> createState() => _CreateLedgerScreenState();
}

class _CreateLedgerScreenState extends State<CreateLedgerScreen> {
  final _nameCtrl = TextEditingController();
  final _balanceCtrl = TextEditingController();
  String _selectedGroup = 'Sundry Debtors';
  final List<String> _groups = ['Sundry Debtors', 'Sundry Creditors', 'Bank Accounts', 'Cash-in-hand', 'Direct Expenses', 'Indirect Expenses', 'Sales Accounts', 'Purchase Accounts'];

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final openBal = double.tryParse(_balanceCtrl.text) ?? 0.0;
    await widget.db.transaction((txn) async {
      final id = await txn.insert('ledgers', {'name': name, 'type': _selectedGroup});
      if (openBal > 0) {
        final isDebtor = _selectedGroup == 'Sundry Debtors' || _selectedGroup == 'Bank Accounts';
        await txn.insert('transactions', {
          'ledger_id': id,
          'type': isDebtor ? 'DR' : 'CR',
          'amount': openBal,
          'note': 'Opening Balance',
          'date': DateTime.now().toString().split(' ')[0],
        });
      }
    });
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Ledger')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Party / Account Name', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedGroup,
              decoration: const InputDecoration(labelText: 'Under Group', border: OutlineInputBorder()),
              items: _groups.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
              onChanged: (v) => setState(() => _selectedGroup = v!),
            ),
            const SizedBox(height: 16),
            TextField(controller: _balanceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Opening Balance', border: OutlineInputBorder())),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0A2E50)),
                onPressed: _save,
                child: const Text('SAVE ACCOUNT', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LedgerDirectoryScreen extends StatelessWidget {
  const LedgerDirectoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ledger Directory')),
      body: const Center(child: Text('Khata List Directory')),
    );
  }
}

class TallyReportsScreen extends StatelessWidget {
  final Database db;
  const TallyReportsScreen({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Financial Reports')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: db.rawQuery('SELECT l.name, l.type, COALESCE(SUM(CASE WHEN t.type = \'DR\' THEN t.amount ELSE 0 END), 0) AS dr, COALESCE(SUM(CASE WHEN t.type = \'CR\' THEN t.amount ELSE 0 END), 0) AS cr FROM ledgers l LEFT JOIN transactions t ON l.id = t.ledger_id GROUP BY l.id'),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final data = snap.data!;
          double inc = 0.0;
          double exp = 0.0;
          for (var r in data) {
            final type = r['type'] as String;
            final dr = (r['dr'] as num).toDouble();
            final cr = (r['cr'] as num).toDouble();
            if (type.contains('Sales') || type.contains('Income')) {
              inc += (cr - dr);
            } else if (type.contains('Expense') || type.contains('Purchase')) {
              exp += (dr - cr);
            }
          }
          final net = inc - exp;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  color: net >= 0 ? Colors.green.shade800 : Colors.red.shade800,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(net >= 0 ? 'Net Profit' : 'Net Loss', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('₹${net.abs().toStringAsFixed(2)}', style: const TextStyle(color: C=> _VoucherEntryScreenState();
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
      appBar: AppBar(title: const Text('New Voucher Entry')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: _entryType == 'DR' ? Colors.green : Colors.grey.shade300),
                    onPressed: () => setState(() => _entryType = 'DR'),
                    child: Text('DEBIT (DR)', style: TextStyle(color: _entryType == 'DR' ? Colors.white : Colors.black)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: _entryType == 'CR' ? Colors.red : Colors.grey.shade300),
                    onPressed: () => setState(() => _entryType = 'CR'),
                    child: Text('CREDIT (CR)', style: TextStyle(color: _entryType == 'CR' ? Colors.white : Colors.black)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _selectedLedgerId,
              decoration: const InputDecoration(labelText: 'Account Name', border: OutlineInputBorder()),
              items: _ledgers.map((l) => DropdownMenuItem<int>(value: l['id'] as int, child: Text('${l['name']} (${l['type']})'))).toList(),
              onChanged: (v) => setState(() => _selectedLedgerId = v),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Amount (₹)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteCtrl,
              decoration: const InputDecoration(labelText: 'Narration / Remark', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0A2E50)),
                onPressed: _saveVoucher,
                child: const Text('SAVE VOUCHER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
    _load();
  }

  Future<void> _load() async {
    final res = await widget.db.rawQuery(
      'SELECT t.id, t.type, t.amount, t.note, t.date, l.name as ledger_name '
      'FROM transactions t '
      'JOIN ledgers l ON t.ledger_id = l.id '
      'ORDER BY t.id DESC',
    );
    setState(() => _list = res);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Day Book')),
      body: _list.isEmpty
          ? const Center(child: Text('Koi transaction nahi hai.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _list.length,
              itemBuilder: (context, idx) {
                final item = _list[idx];
                final isDr = item['type'] == 'DR';
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isDr ? Colors.green.shade100 : Colors.red.shade100,
                      child: Text(item['type'], style: TextStyle(color: isDr ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(item['ledger_name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${item['date']} • ${item['note']}'),
                    trailing: Text('₹${item['amount']}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDr ? Colors.green : Colors.red)),
                  ),
                );
              },
            ),
    );
  }
}

class CreateLedgerScreen extends StatefulWidget {
  final Database db;
  const CreateLedgerScreen({super.key, required this.db});

  @override
  State<CreateLedgerScreen> createState() => _CreateLedgerScreenState();
}

class _CreateLedgerScreenState extends State<CreateLedgerScreen> {
  final _nameCtrl = TextEditingController();
  final _balanceCtrl = TextEditingController();
  String _selectedGroup = 'Sundry Debtors';

  final List<String> _groups = [
    'Sundry Debtors',
    'Sundry Creditors',
    'Bank Accounts',
    'Cash-in-hand',
    'Direct Expenses',
    'Indirect Expenses',
    'Sales Accounts',
    'Purchase Accounts',
  ];

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final openBal = double.tryParse(_balanceCtrl.text) ?? 0.0;
    await widget.db.transaction((txn) async {
      final id = await txn.insert('ledgers', {'name': name, 'type': _selectedGroup});
      if (openBal > 0) {
        final isDebtor = _selectedGroup == 'Sundry Debtors' || _selectedGroup == 'Bank Accounts';
        await txn.insert('transactions', {
          'ledger_id': id,
          'type': isDebtor ? 'DR' : 'CR',
          'amount': openBal,
          'note': 'Opening Balance',
          'date': DateTime.now().toString().split(' ')[0],
        });
      }
    });
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Ledger')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Party / Account Name', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedGroup,
              decoration: const InputDecoration(labelText: 'Under Group', border: OutlineInputBorder()),
              items: _groups.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
              onChanged: (v) => setState(() => _selectedGroup = v!),
            ),
            const SizedBox(height: 16),
            TextField(controller: _balanceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Opening Balance', border: OutlineInputBorder())),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0A2E50)),
                onPressed: _save,
                child: const Text('SAVE ACCOUNT', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LedgerDirectoryScreen extends StatelessWidget {
  final Database db;
  const LedgerDirectoryScreen({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accounts (Khata)')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: db.rawQuery(
          'SELECT l.id, l.name, l.type, '
          'COALESCE(SUM(CASE WHEN t.type = \'DR\' THEN t.amount ELSE 0 END), 0) AS dr, '
          'COALESCE(SUM(CASE WHEN t.type = \'CR\' THEN t.amount ELSE 0 END), 0) AS cr '
          'FROM ledgers l '
          'LEFT JOIN transactions t ON l.id = t.ledger_id '
          'GROUP BY l.id',
        ),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final data = snap.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: data.length,
            itemBuilder: (context, idx) {
              final row = data[idx];
              final double net = (row['dr'] as num).toDouble() - (row['cr'] as 
