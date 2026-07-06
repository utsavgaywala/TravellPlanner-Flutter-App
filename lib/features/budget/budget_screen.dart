import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/trip_model.dart';
import '../providers/app_providers.dart';

/// Budget tracker screen with pie chart, category breakdown, and expense list.
class BudgetScreen extends ConsumerStatefulWidget {
  final String? tripId;
  const BudgetScreen({super.key, this.tripId});
  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  int _selectedTripIndex = 0;

  @override
  void initState() {
    super.initState();
    // If a specific tripId was passed, jump to that trip
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.tripId != null) {
        final trips = ref.read(tripsProvider);
        final idx = trips.indexWhere((t) => t.id == widget.tripId);
        if (idx >= 0 && mounted) setState(() => _selectedTripIndex = idx);
      }
    });
  }

  void _showAddExpense(BuildContext context, Trip trip) {
    final descCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String category = AppConstants.budgetCategories.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Expense', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 24),
              _inputField('Description', descCtrl, LucideIcons.fileText),
              const SizedBox(height: 16),
              _inputField('Amount (₹)', amountCtrl, LucideIcons.coins, isNumber: true),
              const SizedBox(height: 16),
              const Text('Category', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                height: 45,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: AppConstants.budgetCategories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final cat = AppConstants.budgetCategories[i];
                    final sel = category == cat;
                    return GestureDetector(
                      onTap: () => setModalState(() => category = cat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: sel ? Colors.white : Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: sel ? Colors.white : Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Center(child: Text(cat, style: TextStyle(color: sel ? Colors.black : Colors.white60, fontWeight: FontWeight.bold, fontSize: 12))),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    final amt = double.tryParse(amountCtrl.text);
                    if (descCtrl.text.isNotEmpty && amt != null) {
                      final expense = Expense(
                        id: const Uuid().v4(),
                        category: category,
                        description: descCtrl.text,
                        amount: amt,
                        date: DateTime.now(),
                      );
                      ref.read(tripsProvider.notifier).addExpense(trip.id, expense);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: const Text('Save Expense', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController ctrl, IconData icon, {bool isNumber = false}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
      child: TextField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white38),
          prefixIcon: Icon(icon, color: AppColors.accent, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trips = ref.watch(tripsProvider);
    final searchQuery = ref.watch(budgetSearchQueryProvider).toLowerCase();
    
    if (trips.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('🗺️', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 24),
          const Text('No Trips Yet', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('Plan a trip first to track your budget', style: TextStyle(color: Colors.white38)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => ref.read(bottomNavIndexProvider.notifier).state = 1,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            child: const Text('Start Planning', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ])),
      );
    }

    final trip = trips[_selectedTripIndex.clamp(0, trips.length - 1)];
    
    final filteredExpenses = trip.expenses.where((e) {
      return e.description.toLowerCase().contains(searchQuery) || 
             e.category.toLowerCase().contains(searchQuery);
    }).toList();

    final categoryTotals = _getCategoryTotals(trip.expenses);
    final hasExpenses = trip.expenses.isNotEmpty;

    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddExpense(context, trip),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          icon: const Icon(LucideIcons.plus, size: 20),
          label: const Text('Add Expense', style: TextStyle(fontWeight: FontWeight.w900)),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.mainBgGradient),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 140,
              pinned: true,
              automaticallyImplyLeading: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Navigator.canPop(context) 
                ? IconButton(
                    icon: const Icon(LucideIcons.chevronLeft, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ) 
                : null,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text('Budget Tracking', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -1)),
                centerTitle: false,
                titlePadding: const EdgeInsets.only(left: 24, bottom: 20),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Search Bar
                    Container(
                      height: 55,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        children: [
                          Icon(LucideIcons.search, color: Colors.white.withValues(alpha: 0.3), size: 18),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              onChanged: (val) => ref.read(budgetSearchQueryProvider.notifier).state = val,
                              style: const TextStyle(color: Colors.white, fontSize: 15),
                              decoration: InputDecoration(
                                hintText: 'Search expenses...',
                                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Trip selector
                    if (trips.length > 1)
                      Container(
                        height: 50,
                        margin: const EdgeInsets.only(bottom: 24),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: trips.length,
                          itemBuilder: (_, i) {
                            final isSelected = i == _selectedTripIndex;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedTripIndex = i),
                              child: Container(
                                margin: const EdgeInsets.only(right: 12),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                ),
                                child: Center(child: Text(trips[i].destination, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isSelected ? Colors.black : Colors.white.withValues(alpha: 0.4)))),
                              ),
                            );
                          },
                        ),
                      ),

                    // Summary cards
                    Row(children: [
                      Expanded(child: _SummaryCard(title: 'Budget', value: '₹${trip.budget.toStringAsFixed(0)}', icon: LucideIcons.wallet, color: AppColors.accent)),
                      const SizedBox(width: 12),
                      Expanded(child: _SummaryCard(title: 'Spent', value: '₹${trip.totalSpent.toStringAsFixed(0)}', icon: LucideIcons.shoppingBag, color: AppColors.tertiary)),
                      const SizedBox(width: 12),
                      Expanded(child: _SummaryCard(title: 'Left', value: '₹${trip.remainingBudget.toStringAsFixed(0)}', icon: LucideIcons.piggyBank, color: trip.remainingBudget >= 0 ? AppColors.moodRelaxed : Colors.redAccent)),
                    ]),

                    const SizedBox(height: 32),

                    // Progress section
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            const Text('Spending Progress', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('${((trip.totalSpent / (trip.budget > 0 ? trip.budget : 1)) * 100).toStringAsFixed(0)}%', style: const TextStyle(color: AppColors.accent, fontSize: 18, fontWeight: FontWeight.w900)),
                          ]),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: (trip.totalSpent / (trip.budget > 0 ? trip.budget : 1)).clamp(0.0, 1.0),
                              minHeight: 12,
                              backgroundColor: Colors.white.withValues(alpha: 0.1),
                              valueColor: AlwaysStoppedAnimation<Color>(trip.totalSpent / (trip.budget > 0 ? trip.budget : 1) > 0.9 ? Colors.redAccent : AppColors.accent),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (hasExpenses) ...[
                      const SizedBox(height: 32),
                      _sectionHeader('Breakdown'),
                      const SizedBox(height: 16),
                      Container(
                        height: 260,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
                        child: PieChart(PieChartData(
                          sectionsSpace: 4,
                          centerSpaceRadius: 50,
                          sections: categoryTotals.entries.map((e) {
                            final idx = AppConstants.budgetCategories.indexOf(e.key);
                            final color = AppColors.getMoodColor(idx % 4);
                            return PieChartSectionData(
                              value: e.value,
                              color: color,
                              radius: 60,
                              title: '${(e.value / (trip.totalSpent > 0 ? trip.totalSpent : 1) * 100).toStringAsFixed(0)}%',
                              titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white),
                            );
                          }).toList(),
                        )),
                      ),
                      
                      const SizedBox(height: 32),
                      _sectionHeader('Expenses'),
                      const SizedBox(height: 16),
                      if (filteredExpenses.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Text('No expenses match your search', style: TextStyle(color: Colors.white38)),
                        )
                      else
                        ...filteredExpenses.map((exp) => _ExpenseTile(expense: exp)),
                    ] else ...[
                      const SizedBox(height: 60),
                      const Text('💸', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 16),
                      const Text('No expenses recorded', style: TextStyle(color: Colors.white60, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                    const SizedBox(height: 150),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Row(children: [Text(title.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2))]);
  }

  Map<String, double> _getCategoryTotals(List<Expense> expenses) {
    final map = <String, double>{};
    for (final e in expenses) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }
}

class _SummaryCard extends StatelessWidget {
  final String title, value; final IconData icon; final Color color;
  const _SummaryCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(height: 12),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white), overflow: TextOverflow.ellipsis),
      Text(title, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4), fontWeight: FontWeight.w600)),
    ]),
  );
}

class _ExpenseTile extends StatelessWidget {
  final Expense expense;
  const _ExpenseTile({required this.expense});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
    child: Row(children: [
      Container(width: 44, height: 44, decoration: BoxDecoration(color: _getCategoryColor(expense.category).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
        child: Center(child: Text(_getCategoryIcon(expense.category), style: const TextStyle(fontSize: 18)))),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(expense.description, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
        Text(expense.category, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.4))),
      ])),
      Text('₹${expense.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.accent)),
    ]),
  );

  Color _getCategoryColor(String cat) {
    final idx = AppConstants.budgetCategories.indexOf(cat);
    return idx >= 0 && idx < AppColors.budgetColors.length ? AppColors.budgetColors[idx] : AppColors.primary;
  }

  String _getCategoryIcon(String cat) {
    switch (cat) {
      case 'Accommodation': return '🏨';
      case 'Transport': return '🚗';
      case 'Food & Dining': return '🍽️';
      case 'Activities': return '🎯';
      case 'Shopping': return '🛍️';
      default: return '💳';
    }
  }
}
