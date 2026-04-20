import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabunganku/models/transaction_model.dart';
import 'package:tabunganku/providers/transaction_provider.dart';

class MorningCharityStats {
  final double totalAmount;
  final int currentStreak;
  final List<TransactionModel> history;

  MorningCharityStats({
    required this.totalAmount,
    required this.currentStreak,
    required this.history,
  });
}

final morningCharityProvider = Provider<MorningCharityStats>((ref) {
  final transactions = ref.watch(transactionsByGroupProvider(null));
  
  // Filter for Sedekah Subuh transactions
  // They have category 'Gift' and title 'Sedekah Subuh' or description containing 'Sedekah harian'
  final history = transactions.where((t) {
    return t.title.toLowerCase().contains('sedekah subuh') || 
           t.description.toLowerCase().contains('sedekah rutin');
  }).toList()..sort((a, b) => b.date.compareTo(a.date));

  double total = history.fold(0, (sum, t) => sum + t.amount);

  // Calculate streak
  int streak = 0;
  if (history.isNotEmpty) {
    DateTime lastDate = DateTime(history[0].date.year, history[0].date.month, history[0].date.day);
    DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    DateTime yesterday = today.subtract(const Duration(days: 1));

    if (lastDate == today || lastDate == yesterday) {
      streak = 1;
      for (int i = 1; i < history.length; i++) {
        DateTime prevDate = DateTime(history[i-1].date.year, history[i-1].date.month, history[i-1].date.day);
        DateTime currDate = DateTime(history[i].date.year, history[i].date.month, history[i].date.day);
        
        if (prevDate.subtract(const Duration(days: 1)) == currDate) {
          streak++;
        } else if (prevDate == currDate) {
          // Multiple charities in one day don't increase or break streak
          continue;
        } else {
          break;
        }
      }
    }
  }

  return MorningCharityStats(
    totalAmount: total,
    currentStreak: streak,
    history: history,
  );
});
