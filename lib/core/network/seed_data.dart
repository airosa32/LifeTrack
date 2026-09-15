import '../../models/category.dart';
import '../../models/financial_alert.dart';
import '../../models/task.dart';
import '../../models/transaction.dart';

/// Monta o "banco de dados" inicial em memória.
/// Estrutura pensada para ficar idêntica ao que um `db.json` de
/// JSON Server teria, facilitando a migração futura.
Map<String, List<Map<String, dynamic>>> buildSeedStore() {
  final now = DateTime.now();
  DateTime day(int daysAgo, [int hour = 12]) =>
      DateTime(now.year, now.month, now.day - daysAgo, hour);

  final categories = <Category>[
    // Saída
    const Category(id: 'cat-food', name: 'Alimentação', iconKey: 'cart_fill', colorValue: 0xFFFF9F43, type: CategoryType.expense, isDefault: true),
    const Category(id: 'cat-transport', name: 'Transporte', iconKey: 'car_fill', colorValue: 0xFF4A90E2, type: CategoryType.expense, isDefault: true),
    const Category(id: 'cat-housing', name: 'Moradia', iconKey: 'house_fill', colorValue: 0xFF16A085, type: CategoryType.expense, isDefault: true),
    const Category(id: 'cat-bills', name: 'Contas', iconKey: 'bolt_fill', colorValue: 0xFFF1C40F, type: CategoryType.expense, isDefault: true),
    const Category(id: 'cat-shopping', name: 'Compras', iconKey: 'bag_fill', colorValue: 0xFFE84393, type: CategoryType.expense, isDefault: true),
    const Category(id: 'cat-health', name: 'Saúde', iconKey: 'heart_fill', colorValue: 0xFFE74C3C, type: CategoryType.expense, isDefault: true),
    const Category(id: 'cat-education', name: 'Educação', iconKey: 'book_fill', colorValue: 0xFF4A90E2, type: CategoryType.expense, isDefault: true),
    const Category(id: 'cat-leisure', name: 'Lazer', iconKey: 'game_fill', colorValue: 0xFF9B59B6, type: CategoryType.expense, isDefault: true),
    const Category(id: 'cat-card', name: 'Cartão', iconKey: 'creditcard_fill', colorValue: 0xFF34495E, type: CategoryType.expense, isDefault: true),
    const Category(id: 'cat-subscriptions', name: 'Assinaturas', iconKey: 'tv_fill', colorValue: 0xFF9B59B6, type: CategoryType.expense, isDefault: true),
    const Category(id: 'cat-clothing', name: 'Vestuário', iconKey: 'scissors', colorValue: 0xFFE84393, type: CategoryType.expense, isDefault: true),
    const Category(id: 'cat-pets', name: 'Pets', iconKey: 'paw_fill', colorValue: 0xFFFF9F43, type: CategoryType.expense, isDefault: true),
    const Category(id: 'cat-maintenance', name: 'Manutenção', iconKey: 'wrench_fill', colorValue: 0xFF34495E, type: CategoryType.expense, isDefault: true),
    const Category(id: 'cat-other-expense', name: 'Outros', iconKey: 'grid_fill', colorValue: 0xFF8A919B, type: CategoryType.expense, isDefault: true),
    // Entrada
    const Category(id: 'cat-salary', name: 'Salário', iconKey: 'briefcase_fill', colorValue: 0xFF2ECC71, type: CategoryType.income, isDefault: true),
    const Category(id: 'cat-freelance', name: 'Freelance', iconKey: 'desktop_fill', colorValue: 0xFF4A90E2, type: CategoryType.income, isDefault: true),
    const Category(id: 'cat-investment', name: 'Investimentos', iconKey: 'chart_fill', colorValue: 0xFF1ABC9C, type: CategoryType.income, isDefault: true),
    const Category(id: 'cat-sales', name: 'Vendas', iconKey: 'cart_fill', colorValue: 0xFFFF9F43, type: CategoryType.income, isDefault: true),
    const Category(id: 'cat-refund', name: 'Reembolso', iconKey: 'undo_fill', colorValue: 0xFFF1C40F, type: CategoryType.income, isDefault: true),
    const Category(id: 'cat-other-income', name: 'Outros', iconKey: 'gift_fill', colorValue: 0xFFE84393, type: CategoryType.income, isDefault: true),
  ];

  final transactions = <Transaction>[
    Transaction(id: 't1', description: 'Salário', amount: 4000, type: TransactionType.income, categoryId: 'cat-salary', date: day(2)),
    Transaction(id: 't2', description: 'Freelance', amount: 300, type: TransactionType.income, categoryId: 'cat-freelance', date: day(0)),
    Transaction(id: 't3', description: 'Mercado', amount: 150, type: TransactionType.expense, categoryId: 'cat-food', date: day(0), paymentMethod: PaymentMethod.pix),
    Transaction(id: 't4', description: 'Combustível', amount: 100, type: TransactionType.expense, categoryId: 'cat-transport', date: day(0), paymentMethod: PaymentMethod.credit),
    Transaction(id: 't5', description: 'Restaurante', amount: 80, type: TransactionType.expense, categoryId: 'cat-food', date: day(0), paymentMethod: PaymentMethod.credit),
    Transaction(id: 't6', description: 'Academia', amount: 120, type: TransactionType.expense, categoryId: 'cat-health', date: day(1), paymentMethod: PaymentMethod.debit),
    Transaction(id: 't7', description: 'Internet', amount: 100, type: TransactionType.expense, categoryId: 'cat-bills', date: day(3), paymentMethod: PaymentMethod.boleto),
    Transaction(id: 't8', description: 'Streaming', amount: 45, type: TransactionType.expense, categoryId: 'cat-subscriptions', date: day(4), paymentMethod: PaymentMethod.credit, recurrence: RecurrenceType.monthly),
  ];

  final tasks = <Task>[
    Task(id: 'k1', title: 'Estudar Flutter', dueDate: day(0), priority: TaskPriority.high, completed: true, createdAt: day(1), updatedAt: day(0)),
    Task(id: 'k2', title: 'Estudar Dart', dueDate: day(0), priority: TaskPriority.medium, completed: true, createdAt: day(1), updatedAt: day(0)),
    Task(id: 'k3', title: 'Fazer compras', dueDate: day(0), priority: TaskPriority.medium, completed: true, createdAt: day(1), updatedAt: day(0)),
    Task(id: 'k4', title: 'Fazer exercício', dueDate: day(0), priority: TaskPriority.low, createdAt: day(1), updatedAt: day(1)),
    Task(id: 'k5', title: 'Organizar documentos', dueDate: day(0), priority: TaskPriority.urgent, createdAt: day(1), updatedAt: day(1)),
  ];

  final alerts = <FinancialAlert>[
    const FinancialAlert(id: 'a1', name: 'Saldo mínimo', type: AlertType.minimumBalance, value: 500),
    const FinancialAlert(id: 'a2', name: 'Limite mensal de gastos', type: AlertType.maxExpense, value: 2000),
    const FinancialAlert(id: 'a3', name: 'Limite diário', type: AlertType.dailyLimit, value: 100),
    const FinancialAlert(id: 'a4', name: 'Limite de Alimentação', type: AlertType.categoryLimit, value: 500, categoryId: 'cat-food'),
  ];

  return {
    'categories': categories.map((e) => e.toJson()).toList(),
    'transactions': transactions.map((e) => e.toJson()).toList(),
    'tasks': tasks.map((e) => e.toJson()).toList(),
    'alerts': alerts.map((e) => e.toJson()).toList(),
  };
}
