import 'package:fl_chart/fl_chart.dart';
import "package:flutter/material.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/constants.dart';
import '../../../constants/functions.dart';
import '../../../constants/style.dart';
import '../../../model/bank_account.dart';
import 'accounts_tab.dart';

class AccountsPieChart extends ConsumerWidget with Functions {
  const AccountsPieChart({
    required this.accounts,
    required this.amounts,
    required this.total,
    super.key,
  });

  final List<BankAccount> accounts;
  final Map<int, double> amounts;
  final double total;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedAccountIndex = ref.watch(selectedAccountIndexProvider);
    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              startDegreeOffset: -90,
              centerSpaceRadius: 70,
              sectionsSpace: 0,
              borderData: FlBorderData(show: false),
              sections: showingSections(selectedAccountIndex),
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  // expand category when tapped
                  if (!event.isInterestedForInteractions ||
                      pieTouchResponse == null ||
                      pieTouchResponse.touchedSection == null) {
                    return;
                  }
                  ref.read(selectedAccountIndexProvider.notifier).state =
                      pieTouchResponse.touchedSection!.touchedSectionIndex;
                },
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              (selectedAccountIndex != -1)
                  ? Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accountColorList[accounts[selectedAccountIndex].color],
                      ),
                      child: Icon(
                        accountIconList[accounts[selectedAccountIndex].symbol] ??
                            Icons.swap_horiz_rounded,
                        color: Colors.white,
                      ),
                    )
                  : const SizedBox(),
              Text(
                (selectedAccountIndex != -1)
                    ? "${amounts[accounts[selectedAccountIndex].id]!.toStringAsFixed(2)} €"
                    : "${total.toStringAsFixed(2)} €",
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: ((selectedAccountIndex != -1 &&
                                amounts[accounts[selectedAccountIndex].id]! > 0) ||
                            (selectedAccountIndex == -1 && total > 0))
                        ? green
                        : red),
              ),
              (selectedAccountIndex != -1)
                  ? Text(accounts[selectedAccountIndex].name)
                  : const Text("Total"),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections(int index) {
    return List.generate(
      amounts.values.length,
      (i) {
        final isTouched = (i == index);

        final radius = isTouched ? 30.0 : 25.0;
        return PieChartSectionData(
          color: accountColorList[accounts[i].color],
          value: 360 * amounts[accounts[i].id]!,
          radius: radius,
          showTitle: false,
        );
      },
    );
  }
}
