import 'package:cashledger/cash_book/controller/cash_book_controller.dart';
import 'package:cashledger/cash_book/ui/cash_book_add_edit_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CashbookScreen extends ConsumerWidget {
  const CashbookScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(entriesListProvider);

    return Material(
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text("Cashbook"),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.add),
            onPressed: () => Navigator.push(
              context,
              CupertinoPageRoute(builder: (_) => const AddEntryScreen()),
            ),
          ),
        ),
        child: SafeArea(
          child: entriesAsync.when(
            loading: () => const Center(child: CupertinoActivityIndicator()),
            error: (err, _) => Center(
              child: Text(
                "Error: $err",
                style: const TextStyle(color: CupertinoColors.destructiveRed),
              ),
            ),
            data: (entries) {
              double totalReceipts = entries
                  .where((e) => e['type'] == "debit")
                  .fold(0.0, (sum, e) => sum + (e['amount'] ?? 0).toDouble());

              double totalExpenses = entries
                  .where((e) => e['type'] == "credit")
                  .fold(0.0, (sum, e) => sum + (e['amount'] ?? 0).toDouble());

              double balance = totalReceipts - totalExpenses;

              return Column(
                children: [
                  // ----------------------
                  // SUMMARY CARD
                  // ----------------------
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _summaryItem(
                            "Receipts",
                            totalReceipts,
                            CupertinoColors.activeGreen,
                          ),
                          _summaryItem(
                            "Expenses",
                            totalExpenses,
                            CupertinoColors.destructiveRed,
                          ),
                          _summaryItem(
                            "Balance",
                            balance,
                            CupertinoColors.activeBlue,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ----------------------
                  // LIST VIEW
                  // ----------------------
                  Expanded(
                    child: CupertinoListSection.insetGrouped(
                      children: [
                        for (final e in entries)
                          CupertinoListTile(
                            leading: Icon(
                              e['type'] == "debit"
                                  ? CupertinoIcons.arrow_down_circle
                                  : CupertinoIcons.arrow_up_circle,
                              color: e['type'] == "debit"
                                  ? CupertinoColors.activeGreen
                                  : CupertinoColors.destructiveRed,
                            ),
                            title: Text(
                              e['description'] ?? 'No description',
                              style: const TextStyle(fontSize: 16),
                            ),
                            subtitle: Text(
                              "${e['date']} • ${e['accounts']?['name'] ?? 'Unknown account'}",
                              style: const TextStyle(
                                fontSize: 13,
                                color: CupertinoColors.inactiveGray,
                              ),
                            ),
                            trailing: Text(
                              "₹${(e['amount'] ?? 0).toString()}",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: e['type'] == "debit"
                                    ? CupertinoColors.activeGreen
                                    : CupertinoColors.destructiveRed,
                              ),
                            ),

                            // Tap → Edit Screen
                            onTap: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (_) => AddEntryScreen(entry: e),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // -----------------------------------
  //   SUMMARY CARD ITEM BUILDER
  // -----------------------------------
  Widget _summaryItem(String title, double value, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "₹${value.toStringAsFixed(2)}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ],
    );
  }
}
