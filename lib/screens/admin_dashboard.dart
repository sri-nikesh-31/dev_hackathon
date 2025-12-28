import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import 'admin_incident_detail.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final supabase = Supabase.instance.client;

  // ---------------- FILTER STATE ----------------
  String statusFilter = 'all';
  String typeFilter = 'all';
  String timePreset = '24h';

  DateTime? fromDate;
  DateTime? toDate;

  // ---------------- SAFE HELPERS ----------------
  String safeString(dynamic v, [String fallback = ""]) =>
      v == null ? fallback : v.toString();

  bool safeBool(dynamic v) => v == true;

  int safeInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    return 0;
  }

  DateTime safeDate(dynamic v) {
    if (v == null) return DateTime.now();
    return DateTime.tryParse(v.toString()) ?? DateTime.now();
  }

  String formatTime(DateTime dt) {
    return "${dt.day}/${dt.month}/${dt.year} • "
        "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  // ---------------- PRIORITY / SEVERITY ----------------
  int priorityWeight(String p) {
    switch (p) {
      case 'high':
        return 3;
      case 'medium':
        return 2;
      case 'low':
        return 1;
      default:
        return 2;
    }
  }

  int severityScore(Map inc) {
    int score = 0;
    score += priorityWeight(safeString(inc['priority'], 'medium')) * 10;
    score += safeBool(inc['verified']) ? 15 : 0;
    score += safeInt(inc['upvotes']) * 3;
    score += DateTime.now()
        .difference(safeDate(inc['created_at']))
        .inHours
        .clamp(0, 24);
    return score;
  }

  String severityLabel(int score) {
    if (score >= 50) return "Critical";
    if (score >= 35) return "High";
    if (score >= 20) return "Medium";
    return "Low";
  }

  Color severityColor(int score) {
    if (score >= 50) return Colors.red;
    if (score >= 35) return Colors.deepOrange;
    if (score >= 20) return Colors.orange;
    return Colors.green;
  }

  // ---------------- DATE PICKERS ----------------
  Future<void> pickFromDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: fromDate ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        fromDate = date;
        timePreset = 'custom';
      });
    }
  }

  Future<void> pickToDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: toDate ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        toDate = date.add(const Duration(hours: 23, minutes: 59));
        timePreset = 'custom';
      });
    }
  }

  // ---------------- BUILD ----------------
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("🧑‍🚒 Admin Dashboard"),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDark ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: themeProvider.toggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),

      body: FutureBuilder(
        future: supabase.from('incidents').select(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final now = DateTime.now();
          List incidents = snapshot.data as List;

          // -------- STATUS FILTER --------
          incidents = incidents.where((i) {
            if (statusFilter == 'reported') {
              return i['status'] == 'reported' && i['verified'] != true;
            }
            if (statusFilter == 'verified') {
              return i['verified'] == true && i['status'] == 'reported';
            }
            if (statusFilter == 'resolved') {
              return i['status'] == 'resolved';
            }
            return true;
          }).toList();

          // -------- TYPE FILTER --------
          if (typeFilter != 'all') {
            incidents =
                incidents.where((i) => safeString(i['type']) == typeFilter).toList();
          }

          // -------- TIME FILTER --------
          incidents = incidents.where((i) {
            final created = safeDate(i['created_at']);
            if (fromDate != null && toDate != null) {
              return created.isAfter(fromDate!) && created.isBefore(toDate!);
            }
            if (timePreset == '1h') return now.difference(created).inHours <= 1;
            if (timePreset == '6h') return now.difference(created).inHours <= 6;
            if (timePreset == '24h') return now.difference(created).inHours <= 24;
            return true;
          }).toList();

          // -------- SORT BY SEVERITY --------
          incidents.sort((a, b) =>
              severityScore(b).compareTo(severityScore(a)));

          return Column(
            children: [
              // ---------------- FILTER CHIPS ----------------
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    _chip("All", statusFilter == 'all',
                            () => setState(() => statusFilter = 'all')),
                    _chip("Reported", statusFilter == 'reported',
                            () => setState(() => statusFilter = 'reported')),
                    _chip("Verified", statusFilter == 'verified',
                            () => setState(() => statusFilter = 'verified')),
                    _chip("Resolved", statusFilter == 'resolved',
                            () => setState(() => statusFilter = 'resolved')),
                    const SizedBox(width: 16),
                    _chip("Accident", typeFilter == 'Accident',
                            () => setState(() => typeFilter = 'Accident')),
                    _chip("Fire", typeFilter == 'Fire',
                            () => setState(() => typeFilter = 'Fire')),
                    _chip("Medical", typeFilter == 'Medical',
                            () => setState(() => typeFilter = 'Medical')),
                    _chip("All Types", typeFilter == 'all',
                            () => setState(() => typeFilter = 'all')),
                  ],
                ),
              ),

              // -------- CUSTOM DATE RANGE --------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    OutlinedButton(onPressed: pickFromDate, child: const Text("From")),
                    const SizedBox(width: 8),
                    OutlinedButton(onPressed: pickToDate, child: const Text("To")),
                    if (fromDate != null || toDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() {
                          fromDate = null;
                          toDate = null;
                        }),
                      ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // ---------------- LIST ----------------
              Expanded(
                child: incidents.isEmpty
                    ? const Center(child: Text("No incidents"))
                    : ListView.builder(
                  itemCount: incidents.length,
                  itemBuilder: (context, index) {
                    final inc = incidents[index];
                    final score = severityScore(inc);

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AdminIncidentDetail(incident: inc),
                            ),
                          );
                        },
                        leading: Chip(
                          label: Text(severityLabel(score)),
                          backgroundColor:
                          severityColor(score).withOpacity(0.15),
                          labelStyle: TextStyle(
                            color: severityColor(score),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        title: Text(
                          safeString(inc['type'], 'Unknown'),
                          style:
                          const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              safeString(inc['description']),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "🕒 ${formatTime(safeDate(inc['created_at']))}",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Priority: ${safeString(inc['priority'], 'medium')}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),

                        // ---------------- ADMIN ACTIONS ----------------
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                    if (value.startsWith('priority_')) {
                    final newPriority = value.split('_')[1];

                    await supabase
                        .from('incidents')
                        .update({'priority': newPriority})
                        .eq('id', inc['id']);
                    }

                    if (value == 'verify') {
                    await supabase
                        .from('incidents')
                        .update({'verified': true})
                        .eq('id', inc['id']);
                    }

                    if (value == 'unverify') {
                    await supabase
                        .from('incidents')
                        .update({'verified': false})
                        .eq('id', inc['id']);
                    }

                    if (value == 'resolve') {
                    await supabase
                        .from('incidents')
                        .update({'status': 'resolved'})
                        .eq('id', inc['id']);
                    }

                    if (value == 'undo_resolve') {
                    await supabase
                        .from('incidents')
                        .update({'status': 'reported'})
                        .eq('id', inc['id']);
                    }

                    setState(() {});
                    },
                      itemBuilder: (_) => [
                        // ---------- PRIORITY ----------
                        const PopupMenuItem(
                          value: 'priority_high',
                          child: Text("Set High Priority"),
                        ),
                        const PopupMenuItem(
                          value: 'priority_medium',
                          child: Text("Set Medium Priority"),
                        ),
                        const PopupMenuItem(
                          value: 'priority_low',
                          child: Text("Set Low Priority"),
                        ),

                        const PopupMenuDivider(),

                        // ---------- STATUS ----------
                        if (!safeBool(inc['verified']))
                          const PopupMenuItem(
                            value: 'verify',
                            child: Text("Verify"),
                          ),
                        if (safeBool(inc['verified']))
                          const PopupMenuItem(
                            value: 'unverify',
                            child: Text("Undo Verify"),
                          ),
                        if (inc['status'] == 'reported')
                          const PopupMenuItem(
                            value: 'resolve',
                            child: Text("Resolve"),
                          ),
                        if (inc['status'] == 'resolved')
                          const PopupMenuItem(
                            value: 'undo_resolve',
                            child: Text("Undo Resolve"),
                          ),
                      ],
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
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}
