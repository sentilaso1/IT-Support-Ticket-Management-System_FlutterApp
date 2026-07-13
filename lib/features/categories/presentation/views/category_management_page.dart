import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/category_view_model.dart';
import '../../domain/entities/issue_category.dart';

class CategoryManagementPage extends StatefulWidget {
  const CategoryManagementPage({super.key});

  @override
  State<CategoryManagementPage> createState() => _CategoryManagementPageState();
}

class _CategoryManagementPageState extends State<CategoryManagementPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryViewModel>().loadCategories();
    });
  }

  void _showCategoryDialog(BuildContext context, [IssueCategory? category]) {
    final viewModel = context.read<CategoryViewModel>();
    final nameController = TextEditingController(text: category?.categoryName ?? '');
    
    // CHANGE THIS VARIABLE
    final descController = TextEditingController(text: category?.description ?? ''); 
    bool isActive = category?.isActive ?? true;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            title: Text(category == null ? 'Add Category' : 'Edit Category'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Category Name'),
                ),
                const SizedBox(height: 12),
                // REPLACE DROPDOWN WITH THIS TEXTFIELD
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Detailed Description'),
                  maxLines: 2, // Allow 2 lines
                ),
                SwitchListTile(
                  title: const Text('Active'),
                  value: isActive,
                  onChanged: (val) => setState(() => isActive = val),
                )
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final success = await viewModel.saveCategory(
                    category?.id,
                    nameController.text,
                    descController.text, // PASS DATA FROM TEXTFIELD HERE
                    isActive,
                  );
                  if (success && mounted) {
                    Navigator.pop(dialogContext);
                    viewModel.loadCategories();
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CategoryViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Category Management')),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: viewModel.categories.length,
              itemBuilder: (context, index) {
                final cat = viewModel.categories[index];
                return ListTile(
                  title: Text(
                    cat.categoryName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Description: ${cat.description} | ${cat.isActive ? "Active" : "Inactive"}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 12), // Create some breathing space with the Switch button
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1), // Very light blue background
                          borderRadius: BorderRadius.circular(10), // Modern square corners
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.edit_rounded, color: Colors.blue, size: 20),
                          tooltip: 'Edit', // Tooltip on hover
                          onPressed: () => _showCategoryDialog(context, cat),
                        ),
                      ),
                      Switch(
                        value: cat.isActive,
                        activeColor: Colors.green, // Green color when active
                        onChanged: (bool newValue) {
                          // Reuse saveCategory function to update status
                          viewModel.saveCategory(
                            cat.id,
                            cat.categoryName,
                            cat.description,
                            newValue,
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
