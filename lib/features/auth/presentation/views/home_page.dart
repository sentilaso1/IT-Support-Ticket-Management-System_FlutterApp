import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../assignment/presentation/viewmodels/technician_queue_view_model.dart';
import '../../../assignment/presentation/views/technician_queue_page.dart';
import 'login_page.dart';
import '../viewmodels/login_view_model.dart';
import '../../../user_management/presentation/views/user_list_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.viewModel});

  final LoginViewModel viewModel;

  Future<void> _logout(BuildContext context) async {
    await viewModel.logout();

    if (!context.mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginPage(viewModel: viewModel)),
      (route) => false,
    );
  }

  Future<void> _openAssignedTickets(BuildContext context) async {
    final user = viewModel.currentUser;
    if (user == null) {
      return;
    }

    final service = await ServiceLocator.assignmentService;
    if (!context.mounted) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TechnicianQueuePage(
          viewModel: TechnicianQueueViewModel(
            assignmentService: service,
            staffId: user.id,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = viewModel.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CircleAvatar(
                      radius: 36,
                      child: Text(
                        user == null || user.fullName.isEmpty
                            ? '?'
                            : user.fullName.substring(0, 1).toUpperCase(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.fullName ?? 'No user',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user?.email ?? 'No email',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Role: ${user?.role ?? 'unknown'}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    if (user?.role == 'admin') ...[
                      FilledButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const UserListPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.manage_accounts_outlined),
                        label: const Text('Manage users'),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (user?.role == 'staff') ...[
                      FilledButton.icon(
                        onPressed: () => _openAssignedTickets(context),
                        icon: const Icon(Icons.assignment_ind),
                        label: const Text('Assigned tickets'),
                      ),
                      const SizedBox(height: 12),
                    ],
                    OutlinedButton.icon(
                      onPressed: () => _logout(context),
                      icon: const Icon(Icons.logout),
                      label: const Text('Sign out'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
