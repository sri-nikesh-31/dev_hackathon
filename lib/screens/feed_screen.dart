import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

import 'incident_detail_screen.dart';
import 'admin_dashboard.dart';
import 'report_screen.dart';
import '../theme_provider.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final supabase = Supabase.instance.client;

  bool isAdmin = false;
  bool roleLoaded = false;
  Key streamKey = UniqueKey();

  // ---------------- FILTER STATE ----------------
  String typeFilter = 'all';        // all | Accident | Fire | Medical
  String timeFilter = '24h';        // 1h | 6h | 24h | all | custom

  DateTime? fromDate;               // ✅ custom range
  DateTime? toDate;

  // ---------------- INIT ----------------
  @override
  void initState() {
    super.initState();
    loadRole();
  }

  Future<void> loadRole() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final profile = await supabase
        .from('profiles')
        .select('is_admin')
        .eq('id', user.id)
        .single();

    setState(() {
      isAdmin = profile['is_admin'] == true;
      roleLoaded = true;
    });
  }

  void refreshFeed() {
    setState(() => streamKey = UniqueKey());
  }

  // ---------------- SAFE HELPERS ----------------
  String safeString(dynamic v, [String fallback = ""]) =>
      v == null ? fallback : v.toString();

  int safeInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    return 0;
  }

  bool safeBool(dynamic v) => v == true;

  double safeDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return 0.0;
  }

  DateTime safeDate(dynamic v) {
    if (v == null) return DateTime.now();
    return DateTime.tryParse(v.toString()) ?? DateTime.now();
  }

  // ---------------- UI HELPERS ----------------
  Color severityColor(bool verified, int upvotes) {
    if (verified) return Colors.redAccent;
    if (upvotes >= 1) return Colors.orangeAccent;
    return Colors.grey;
  }

  String severityLabel(bool verified, int upvotes) {
    if (verified) return "Verified";
    if (upvotes >= 1) return "Unverified";
    return "New";
  }

  String formatTime(DateTime dt) {
    return "${dt.day}/${dt.month}/${dt.year} • "
        "${dt.hour.toString().padLeft(2, '0')}:"
        "${dt.minute.toString().padLeft(2, '0')}";
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
        timeFilter = 'custom';
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
        timeFilter = 'custom';
      });
    }
  }

  // ---------------- BUILD ----------------
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("🚨 Live Incidents"),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDark ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: themeProvider.toggleTheme,
          ),
          if (roleLoaded && isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminDashboard()),
                ).then((_) => refreshFeed());
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await supabase.auth.signOut();
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text("Report"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ReportScreen()),
          ).then((_) => refreshFeed());
        },
      ),

      body: Column(
        children: [
          // ---------------- FILTER ROW 1 (TYPE + PRESET TIME) ----------------
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _chip("All", typeFilter == 'all',
                        () => setState(() => typeFilter = 'all')),
                _chip("Accident", typeFilter == 'Accident',
                        () => setState(() => typeFilter = 'Accident')),
                _chip("Fire", typeFilter == 'Fire',
                        () => setState(() => typeFilter = 'Fire')),
                _chip("Medical", typeFilter == 'Medical',
                        () => setState(() => typeFilter = 'Medical')),
                const SizedBox(width: 16),
                _chip("1h", timeFilter == '1h',
                        () => setState(() => timeFilter = '1h')),
                _chip("6h", timeFilter == '6h',
                        () => setState(() => timeFilter = '6h')),
                _chip("24h", timeFilter == '24h',
                        () => setState(() => timeFilter = '24h')),
                _chip("All time", timeFilter == 'all',
                        () => setState(() => timeFilter = 'all')),
              ],
            ),
          ),

          // ---------------- FILTER ROW 2 (CUSTOM RANGE) ----------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                OutlinedButton(
                  onPressed: pickFromDate,
                  child: Text(fromDate == null
                      ? "From"
                      : "${fromDate!.day}/${fromDate!.month}/${fromDate!.year}"),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: pickToDate,
                  child: Text(toDate == null
                      ? "To"
                      : "${toDate!.day}/${toDate!.month}/${toDate!.year}"),
                ),
                if (fromDate != null || toDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        fromDate = null;
                        toDate = null;
                        timeFilter = '24h';
                      });
                    },
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          // ---------------- FEED ----------------
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              key: streamKey,
              stream: supabase
                  .from('incidents')
                  .stream(primaryKey: ['id'])
                  .neq('status', 'resolved')
                  .order('created_at', ascending: false),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final now = DateTime.now();

                List<Map<String, dynamic>> data =
                snapshot.data!.map((raw) {
                  return {
                    'id': raw['id'],
                    'type': safeString(raw['type'], 'Unknown'),
                    'description': safeString(raw['description']),
                    'upvotes': safeInt(raw['upvotes']),
                    'verified': safeBool(raw['verified']),
                    'latitude': safeDouble(raw['latitude']),
                    'longitude': safeDouble(raw['longitude']),
                    'created_at': safeDate(raw['created_at']),
                    'image_url': raw['image_url'],
                  };
                }).toList();

                // -------- TIME FILTER --------
                data = data.where((i) {
                  final created = i['created_at'] as DateTime;

                  if (fromDate != null && toDate != null) {
                    return created.isAfter(fromDate!) &&
                        created.isBefore(toDate!);
                  }

                  if (timeFilter == '1h') {
                    return now.difference(created).inHours <= 1;
                  }
                  if (timeFilter == '6h') {
                    return now.difference(created).inHours <= 6;
                  }
                  if (timeFilter == '24h') {
                    return now.difference(created).inHours <= 24;
                  }
                  return true;
                }).toList();

                // -------- TYPE FILTER --------
                if (typeFilter != 'all') {
                  data = data.where((i) => i['type'] == typeFilter).toList();
                }

                if (data.isEmpty) {
                  return const Center(child: Text("No incidents"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final inc = data[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  IncidentDetailScreen(incident: inc),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (inc['image_url'] != null)
                              ClipRRect(
                                borderRadius:
                                const BorderRadius.vertical(top: Radius.circular(16)),
                                child: Image.network(
                                  inc['image_url'],
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                  const SizedBox(height: 180, child: Icon(Icons.broken_image)),
                                ),
                              ),

                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          inc['type'],
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Chip(
                                        label: Text(
                                          severityLabel(
                                              inc['verified'], inc['upvotes']),
                                        ),
                                        backgroundColor: severityColor(
                                            inc['verified'], inc['upvotes'])
                                            .withOpacity(0.15),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "🕒 ${formatTime(safeDate(inc['created_at']))}",
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    inc['description'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              inc['verified']
                                                  ? Icons.verified
                                                  : Icons.warning_amber_rounded,
                                              color: severityColor(
                                                  inc['verified'], inc['upvotes']),
                                            ),
                                            onPressed: () async {
                                              try {
                                                await supabase.rpc(
                                                  'increment_upvote',
                                                  params: {
                                                    'incident_id': inc['id']
                                                  },
                                                );
                                              } catch (_) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                      content: Text(
                                                          "Already confirmed")),
                                                );
                                              }
                                            },
                                          ),
                                          Text("${inc['upvotes']} confirmations"),
                                        ],
                                      ),
                                      TextButton.icon(
                                        icon: const Icon(Icons.map_outlined),
                                        label: const Text("View map"),
                                        onPressed: () {
                                          final url = Uri.parse(
                                            "https://www.google.com/maps/search/?api=1&query=${inc['latitude']},${inc['longitude']}",
                                          );
                                          launchUrl(url,
                                              mode: LaunchMode.externalApplication);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
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
