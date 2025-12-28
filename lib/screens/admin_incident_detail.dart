import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminIncidentDetail extends StatefulWidget {
  final Map<String, dynamic> incident;

  const AdminIncidentDetail({super.key, required this.incident});

  @override
  State<AdminIncidentDetail> createState() => _AdminIncidentDetailState();
}

class _AdminIncidentDetailState extends State<AdminIncidentDetail> {
  final supabase = Supabase.instance.client;
  late Map<String, dynamic> inc;
  late TextEditingController notesCtrl;

  // ---------------- SAFE HELPERS ----------------

  String safeString(dynamic v, [String fallback = ""]) =>
      v == null ? fallback : v.toString();

  bool safeBool(dynamic v) => v == true;

  @override
  void initState() {
    super.initState();
    inc = widget.incident;
    notesCtrl =
        TextEditingController(text: safeString(inc['admin_notes']));
  }

  Color priorityColor(String p) {
    if (p == 'high') return Colors.red;
    if (p == 'low') return Colors.green;
    return Colors.orange;
  }

  Future<void> refresh() async {
    final data = await supabase
        .from('incidents')
        .select()
        .eq('id', inc['id'])
        .single();
    setState(() => inc = data);
  }

  @override
  Widget build(BuildContext context) {
    final type = safeString(inc['type'], 'Unknown');
    final status = safeString(inc['status'], 'reported');
    final priority = safeString(inc['priority'], 'medium');
    final desc = safeString(inc['description']);
    final lat = inc['latitude'];
    final lng = inc['longitude'];

    return Scaffold(
      appBar: AppBar(title: const Text("🚨 Incident Detail")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (inc['image_url'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  inc['image_url'],
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Text(
                    type,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Chip(label: Text(status)),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              "Priority: $priority",
              style: TextStyle(
                color: priorityColor(priority),
                fontWeight: FontWeight.bold,
              ),
            ),

            const Divider(height: 32),

            Text(desc),

            const Divider(height: 32),

            Text("Lat: $lat\nLng: $lng"),
            TextButton.icon(
              icon: const Icon(Icons.map),
              label: const Text("Open in Maps"),
              onPressed: () {
                final url = Uri.parse(
                  "https://www.google.com/maps/search/?api=1&query=$lat,$lng",
                );
                launchUrl(url,
                    mode: LaunchMode.externalApplication);
              },
            ),

            const Divider(height: 32),

            TextField(
              controller: notesCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Only visible to responders",
              ),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              child: const Text("Save Notes"),
              onPressed: () async {
                await supabase.from('incidents').update({
                  'admin_notes': notesCtrl.text,
                }).eq('id', inc['id']);
                await refresh();
              },
            ),

            const Divider(height: 32),

            Wrap(
              spacing: 12,
              children: [
                if (!safeBool(inc['verified']))
                  ElevatedButton.icon(
                    icon: const Icon(Icons.verified),
                    label: const Text("Verify"),
                    onPressed: () async {
                      await supabase
                          .from('incidents')
                          .update({'verified': true})
                          .eq('id', inc['id']);
                      await refresh();
                    },
                  ),
                if (status == 'reported')
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle),
                    label: const Text("Resolve"),
                    onPressed: () async {
                      await supabase
                          .from('incidents')
                          .update({'status': 'resolved'})
                          .eq('id', inc['id']);
                      await refresh();
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
