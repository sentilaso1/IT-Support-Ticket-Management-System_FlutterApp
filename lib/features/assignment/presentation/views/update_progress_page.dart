import 'package:flutter/material.dart';

import '../viewmodels/update_progress_view_model.dart';

class UpdateProgressPage extends StatefulWidget {
  const UpdateProgressPage({super.key, required this.viewModel});

  final UpdateProgressViewModel viewModel;

  @override
  State<UpdateProgressPage> createState() => _UpdateProgressPageState();
}

class _UpdateProgressPageState extends State<UpdateProgressPage> {
  final TextEditingController _messageController = TextEditingController();
  double _progress = 25;
  String _status = 'In Progress';

  static const List<String> _statuses = [
    'Open',
    'In Progress',
    'Resolved',
    'Closed',
  ];

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_onViewModelChanged);
    widget.viewModel.load();
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onViewModelChanged);
    _messageController.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _submit() async {
    final success = await widget.viewModel.submitUpdate(
      message: _messageController.text,
      progressPercent: _progress.round(),
      status: _status,
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'Progress updated.' : 'Update failed.')),
    );

    if (success) {
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    final assignment = viewModel.assignment;
    return Scaffold(
      appBar: AppBar(title: const Text('Update progress')),
      body: viewModel.isLoading && assignment == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (viewModel.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      viewModel.errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                if (assignment != null) ...[
                  Text(
                    assignment.ticketTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(assignment.ticketDescription),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(label: Text(assignment.priority)),
                      Chip(label: Text(assignment.issueType)),
                      Chip(label: Text('Current: ${assignment.status}')),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: const InputDecoration(
                    labelText: 'New status',
                    border: OutlineInputBorder(),
                  ),
                  items: _statuses
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ),
                      )
                      .toList(),
                  onChanged: viewModel.isLoading
                      ? null
                      : (value) => setState(() => _status = value ?? _status),
                ),
                const SizedBox(height: 16),
                Text('Progress: ${_progress.round()}%'),
                Slider(
                  value: _progress,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  label: '${_progress.round()}%',
                  onChanged: viewModel.isLoading
                      ? null
                      : (value) => setState(() => _progress = value),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _messageController,
                  minLines: 4,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Progress note',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: viewModel.isLoading ? null : _submit,
                  icon: viewModel.isLoading
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: const Text('Save update'),
                ),
                const SizedBox(height: 24),
                Text(
                  'Progress history',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (viewModel.updates.isEmpty)
                  const Text('No progress notes yet.')
                else
                  ...viewModel.updates.map(
                    (update) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.notes),
                      title: Text(update.message),
                      subtitle: Text(
                        '${update.progressPercent ?? 0}% - ${update.createdAt}',
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
