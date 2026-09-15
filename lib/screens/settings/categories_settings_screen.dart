import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/category_icons.dart';
import '../../core/utils/validators.dart';
import '../../models/category.dart';
import '../../providers/finance_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/state_widgets.dart';
import '../../widgets/finance/category_avatar.dart';

class CategoriesSettingsScreen extends ConsumerStatefulWidget {
  const CategoriesSettingsScreen({super.key});

  @override
  ConsumerState<CategoriesSettingsScreen> createState() => _CategoriesSettingsScreenState();
}

class _CategoriesSettingsScreenState extends ConsumerState<CategoriesSettingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _openCreateDialog(CategoryType type) async {
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String selectedIconKey = CategoryIconRegistry.pickableKeys.first;
    int selectedColorIndex = 0;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final previewCategory = Category(
              id: 'preview',
              name: nameController.text.trim().isEmpty ? 'Categoria' : nameController.text.trim(),
              iconKey: selectedIconKey,
              colorValue: CategoryIconRegistry.colorAt(selectedColorIndex).value,
              type: type,
            );

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CategoryAvatar(category: previewCategory, size: 44),
                          const SizedBox(width: 12),
                          Text('Nova categoria', style: Theme.of(context).textTheme.titleLarge),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Nome',
                        controller: nameController,
                        validator: Validators.requiredField,
                        prefixIcon: const Icon(CupertinoIcons.textformat),
                      ),
                      const SizedBox(height: 20),
                      Text('Ícone', style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: CategoryIconRegistry.pickableKeys.map((key) {
                          final selected = key == selectedIconKey;
                          final color = CategoryIconRegistry.colorAt(selectedColorIndex);
                          return GestureDetector(
                            onTap: () => setModalState(() => selectedIconKey = key),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: selected ? color : color.withOpacity(0.15),
                                shape: BoxShape.circle,
                                border: selected
                                    ? Border.all(color: Theme.of(context).colorScheme.onSurface, width: 2)
                                    : null,
                              ),
                              child: Icon(
                                CategoryIconRegistry.resolve(key),
                                color: selected ? Colors.white : color,
                                size: 20,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      Text('Cor', style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: List.generate(CategoryIconRegistry.colorPalette.length, (i) {
                          final color = CategoryIconRegistry.colorAt(i);
                          final selected = i == selectedColorIndex;
                          return GestureDetector(
                            onTap: () => setModalState(() => selectedColorIndex = i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: selected
                                    ? Border.all(color: Theme.of(context).colorScheme.onSurface, width: 2)
                                    : null,
                              ),
                              child: selected
                                  ? const Icon(CupertinoIcons.checkmark, color: Colors.white, size: 16)
                                  : null,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 24),
                      AppButton(
                        label: 'Criar categoria',
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          final category = Category(
                            id: const Uuid().v4(),
                            name: nameController.text.trim(),
                            iconKey: selectedIconKey,
                            colorValue: CategoryIconRegistry.colorAt(selectedColorIndex).value,
                            type: type,
                          );
                          await ref.read(categoryListProvider.notifier).addCategory(category);
                          if (context.mounted) Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir categoria?'),
        content: Text('"${category.name}" será removida. Esta ação não poderá ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Excluir')),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(categoryListProvider.notifier).deleteCategory(category.id);
    }
  }

  Widget _buildList(CategoryType type, List<Category> categories) {
    final filtered = categories.where((c) => c.type == type).toList();
    if (filtered.isEmpty) {
      return const EmptyState(message: 'Nenhuma categoria cadastrada.');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final category = filtered[index];
        return ListTile(
          leading: CategoryAvatar(category: category, size: 40),
          title: Text(category.name),
          subtitle: category.isDefault ? const Text('Categoria padrão') : const Text('Personalizada'),
          trailing: category.isDefault
              ? null
              : IconButton(
                  icon: const Icon(CupertinoIcons.delete),
                  onPressed: () => _confirmDelete(category),
                ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorias'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Saídas'), Tab(text: 'Entradas')],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCreateDialog(
          _tabController.index == 0 ? CategoryType.expense : CategoryType.income,
        ),
        child: const Icon(CupertinoIcons.add),
      ),
      body: categoriesAsync.when(
        loading: () => const LoadingState(),
        error: (_, __) => const ErrorState(),
        data: (categories) => TabBarView(
          controller: _tabController,
          children: [
            _buildList(CategoryType.expense, categories),
            _buildList(CategoryType.income, categories),
          ],
        ),
      ),
    );
  }
}
