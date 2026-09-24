/// Core: Routing — App Router
///
/// Mendefinisikan semua route navigasi menggunakan GoRouter.
/// Route dikelompokkan berdasarkan feature area dengan komentar section.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ── Auth & Shell ──────────────────────────────────────────────────────────────
import 'package:tabunganku/features/auth/presentation/pages/lock_screen.dart';
import 'package:tabunganku/features/splash/presentation/pages/splash_screen.dart';

// ── Home / Dashboard ──────────────────────────────────────────────────────────
import 'package:tabunganku/features/home/presentation/pages/dashboard_page.dart';

// ── Settings ──────────────────────────────────────────────────────────────────
import 'package:tabunganku/features/settings/presentation/pages/feedback_page.dart';
import 'package:tabunganku/features/settings/presentation/pages/pin_setup_page.dart';

// ── Savings & Targets ─────────────────────────────────────────────────────────
import 'package:tabunganku/features/home/presentation/pages/buying_targets_page.dart';
import 'package:tabunganku/features/home/presentation/pages/gold_savings_page.dart';
import 'package:tabunganku/features/home/presentation/pages/round_up_savings_page.dart';
import 'package:tabunganku/features/home/presentation/pages/saving_streak_page.dart';
import 'package:tabunganku/features/home/presentation/pages/piggy_bank_page.dart';
import 'package:tabunganku/features/home/presentation/pages/saving_plans_page.dart';
import 'package:tabunganku/features/home/presentation/pages/saving_simulator_page.dart';
import 'package:tabunganku/features/home/presentation/pages/specialized_saving_page.dart';

// ── Transactions & Debt ───────────────────────────────────────────────────────
import 'package:tabunganku/features/transaction/presentation/pages/debt_list_page.dart';
import 'package:tabunganku/features/transaction/presentation/pages/recurring_list_page.dart';

// ── Bills & Budget ────────────────────────────────────────────────────────────
import 'package:tabunganku/features/budget/presentation/pages/monthly_budget_page.dart';
import 'package:tabunganku/features/home/presentation/pages/billing_management_page.dart';
import 'package:tabunganku/features/home/presentation/pages/bills_tracker_page.dart';
import 'package:tabunganku/features/home/presentation/pages/budget_rule_page.dart';
import 'package:tabunganku/features/home/presentation/pages/payday_vault_page.dart';
import 'package:tabunganku/features/home/presentation/pages/shopping_budget_page.dart';

// ── Tax & Insurance ───────────────────────────────────────────────────────────
import 'package:tabunganku/features/home/presentation/pages/insurance_tracker_page.dart';
import 'package:tabunganku/features/home/presentation/pages/investment_tracker_page.dart';
import 'package:tabunganku/features/home/presentation/pages/tax_calculator_page.dart';
import 'package:tabunganku/features/home/presentation/pages/tax_reminder_page.dart';

// ── Financial Calculators ─────────────────────────────────────────────────────
import 'package:tabunganku/features/home/presentation/pages/compound_interest_page.dart';
import 'package:tabunganku/features/home/presentation/pages/debt_payoff_planner_page.dart';
import 'package:tabunganku/features/home/presentation/pages/early_retirement_page.dart';
import 'package:tabunganku/features/home/presentation/pages/emergency_fund_calculator_page.dart';
import 'package:tabunganku/features/home/presentation/pages/inflation_calculator_page.dart';
import 'package:tabunganku/features/home/presentation/pages/kpr_calculator_page.dart';
import 'package:tabunganku/features/home/presentation/pages/net_salary_calculator_page.dart';
import 'package:tabunganku/features/home/presentation/pages/rule_of_72_page.dart';
import 'package:tabunganku/features/home/presentation/pages/split_bill_page.dart';
import 'package:tabunganku/features/home/presentation/pages/time_value_money_page.dart';

// ── Currency & Market ─────────────────────────────────────────────────────────
import 'package:tabunganku/features/home/presentation/pages/currency_converter_page.dart';

// ── Planners ──────────────────────────────────────────────────────────────────
import 'package:tabunganku/features/budget/presentation/pages/overseas_travel_page.dart';
import 'package:tabunganku/features/home/presentation/pages/hajj_umrah_planner_page.dart';
import 'package:tabunganku/features/home/presentation/pages/kuliah_planner_page.dart';
import 'package:tabunganku/features/home/presentation/pages/nikah_planner_page.dart';
import 'package:tabunganku/features/home/presentation/pages/wisata_planner_page.dart';

// ── Islamic Finance ───────────────────────────────────────────────────────────
import 'package:tabunganku/features/home/presentation/pages/hutang_jariyah_page.dart';
import 'package:tabunganku/features/home/presentation/pages/mosque_donation_page.dart';
import 'package:tabunganku/features/home/presentation/pages/ramadan_mode_page.dart';
import 'package:tabunganku/features/home/presentation/pages/zakat_page.dart';

// ── Notes ─────────────────────────────────────────────────────────────────────
import 'package:tabunganku/features/home/presentation/pages/note_detail_page.dart';
import 'package:tabunganku/features/home/presentation/pages/notes_page.dart';
import 'package:tabunganku/models/note_model.dart';

// ── Social & Emergency ────────────────────────────────────────────────────────
import 'package:tabunganku/features/challenge/presentation/pages/challenge_page.dart';
import 'package:tabunganku/features/home/presentation/pages/brankas_finansial_page.dart';
import 'package:tabunganku/features/home/presentation/pages/kontak_darurat_finansial_page.dart';
import 'package:tabunganku/features/nabung_bersama/presentation/pages/nabung_bersama_page.dart';

// ── Shopping ──────────────────────────────────────────────────────────────────
import 'package:tabunganku/features/shopping/presentation/pages/shopping_list_page.dart';

// ── All Services ──────────────────────────────────────────────────────────────
import 'package:tabunganku/features/home/presentation/pages/all_services_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context)
                  .pushNamedAndRemoveUntil('/splash', (_) => false),
              child: const Text('Kembali ke Awal'),
            ),
          ],
        ),
      ),
    ),
    routes: [
      // ── Auth & Shell ────────────────────────────────────────────────────────
      GoRoute(
        path: '/',
        name: 'home',
        redirect: (_, __) => '/splash',
      ),
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/lock',
        name: 'lock',
        builder: (_, __) => const LockScreen(),
      ),

      // ── Settings ────────────────────────────────────────────────────────────
      GoRoute(
        path: '/pin-setup',
        name: 'pin-setup',
        builder: (_, __) => const PinSetupPage(),
      ),
      GoRoute(
        path: '/feedback',
        name: 'feedback',
        builder: (_, __) => const FeedbackPage(),
      ),

      // ── Home / Dashboard ────────────────────────────────────────────────────
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (_, __) => const DashboardPage(),
      ),
      GoRoute(
        path: '/all-services',
        name: 'all-services',
        builder: (_, __) => const AllServicesPage(),
      ),

      // ── Savings & Targets ────────────────────────────────────────────────────
      GoRoute(
        path: '/saving-simulator',
        name: 'saving-simulator',
        builder: (_, __) => const SavingSimulatorPage(),
      ),
      GoRoute(
        path: '/saving-plans',
        name: 'saving-plans',
        builder: (_, __) => const SavingPlansPage(),
      ),
      GoRoute(
        path: '/buying-targets',
        name: 'buying-targets',
        builder: (_, __) => const BuyingTargetsPage(),
      ),
      GoRoute(
        path: '/gold',
        name: 'gold',
        builder: (_, __) => const GoldSavingsPage(),
      ),
      GoRoute(
        path: '/piggy-bank',
        name: 'piggy-bank',
        builder: (_, __) => const PiggyBankPage(),
      ),
      GoRoute(
        path: '/saving-streak',
        name: 'saving-streak',
        builder: (_, __) => const SavingStreakPage(),
      ),
      GoRoute(
        path: '/round-up-savings',
        name: 'round-up-savings',
        builder: (_, __) => const RoundUpSavingsPage(),
      ),
      GoRoute(
        path: '/emergency-fund',
        name: 'emergency-fund',
        builder: (_, __) => const SpecializedSavingPage(
          title: 'Dana Darurat',
          category: 'Darurat',
          icon: Icons.health_and_safety_rounded,
          baseColor: Colors.redAccent,
        ),
      ),
      GoRoute(
        path: '/education-fund',
        name: 'education-fund',
        builder: (_, __) => const SpecializedSavingPage(
          title: 'Dana Pendidikan',
          category: 'Pendidikan',
          icon: Icons.school_rounded,
          baseColor: Colors.blueAccent,
        ),
      ),
      GoRoute(
        path: '/retirement-fund',
        name: 'retirement-fund',
        builder: (_, __) => const SpecializedSavingPage(
          title: 'Dana Pensiun',
          category: 'Pensiun',
          icon: Icons.elderly_rounded,
          baseColor: Colors.brown,
        ),
      ),
      GoRoute(
        path: '/qurban',
        name: 'qurban',
        builder: (_, __) => const SpecializedSavingPage(
          title: 'Tabungan Kurban',
          category: 'Kurban',
          icon: Icons.pets_rounded,
          baseColor: Colors.green,
        ),
      ),

      // ── Transactions & Debt ──────────────────────────────────────────────────
      GoRoute(
        path: '/recurring',
        name: 'recurring',
        builder: (_, __) => const RecurringListPage(),
      ),
      GoRoute(
        path: '/debts',
        name: 'debts',
        builder: (_, __) => const DebtListPage(),
      ),

      // ── Bills & Budget ───────────────────────────────────────────────────────
      GoRoute(
        path: '/monthly-budget',
        name: 'monthly-budget',
        builder: (_, __) => const MonthlyBudgetPage(),
      ),
      GoRoute(
        path: '/bills',
        name: 'bills',
        builder: (_, __) => const BillingManagementPage(),
      ),
      GoRoute(
        path: '/bills-tracker',
        name: 'bills-tracker',
        builder: (_, __) => const BillsTrackerPage(),
      ),
      GoRoute(
        path: '/budget-rule',
        name: 'budget-rule',
        builder: (_, __) => const BudgetRulePage(),
      ),
      GoRoute(
        path: '/payday-vault',
        name: 'payday-vault',
        builder: (_, __) => const PaydayVaultPage(),
      ),
      GoRoute(
        path: '/shopping-budget',
        name: 'shopping-budget',
        builder: (_, __) => const ShoppingBudgetPage(),
      ),

      // ── Tax & Insurance ──────────────────────────────────────────────────────
      GoRoute(
        path: '/tax',
        name: 'tax',
        builder: (_, __) => const TaxCalculatorPage(),
      ),
      GoRoute(
        path: '/tax-reminder',
        name: 'tax-reminder',
        builder: (_, __) => const TaxReminderPage(),
      ),
      GoRoute(
        path: '/investment',
        name: 'investment',
        builder: (_, __) => const InvestmentTrackerPage(),
      ),
      GoRoute(
        path: '/insurance',
        name: 'insurance',
        builder: (_, __) => const InsuranceTrackerPage(),
      ),

      // ── Financial Calculators ────────────────────────────────────────────────
      GoRoute(
        path: '/net-salary',
        name: 'net-salary',
        builder: (_, __) => const NetSalaryCalculatorPage(),
      ),
      GoRoute(
        path: '/compound-interest',
        name: 'compound-interest',
        builder: (_, __) => const CompoundInterestPage(),
      ),
      GoRoute(
        path: '/debt-payoff',
        name: 'debt-payoff',
        builder: (_, __) => const DebtPayoffPlannerPage(),
      ),
      GoRoute(
        path: '/kpr-calculator',
        name: 'kpr-calculator',
        builder: (_, __) => const KPRCalculatorPage(),
      ),
      GoRoute(
        path: '/emergency-fund-calculator',
        name: 'emergency-fund-calculator',
        builder: (_, __) => const EmergencyFundCalculatorPage(),
      ),
      GoRoute(
        path: '/inflation-calculator',
        name: 'inflation-calculator',
        builder: (_, __) => const InflationCalculatorPage(),
      ),
      GoRoute(
        path: '/rule-of-72',
        name: 'rule-of-72',
        builder: (_, __) => const RuleOf72Page(),
      ),
      GoRoute(
        path: '/split-bill',
        name: 'split-bill',
        builder: (_, __) => const SplitBillPage(),
      ),
      GoRoute(
        path: '/early-retirement',
        name: 'early-retirement',
        builder: (_, __) => const EarlyRetirementPage(),
      ),
      GoRoute(
        path: '/time-value-money',
        name: 'time-value-money',
        builder: (_, __) => const TimeValueMoneyPage(),
      ),

      // ── Currency & Market ────────────────────────────────────────────────────
      GoRoute(
        path: '/currency-converter',
        name: 'currency-converter',
        builder: (_, __) => const CurrencyConverterPage(),
      ),

      // ── Planners ─────────────────────────────────────────────────────────────
      GoRoute(
        path: '/overseas-travel',
        name: 'overseas-travel',
        builder: (_, __) => const OverseasTravelPage(),
      ),
      GoRoute(
        path: '/hajj-umrah',
        name: 'hajj-umrah',
        builder: (_, __) => const HajjUmrahPlannerPage(),
      ),
      GoRoute(
        path: '/nikah-planner',
        name: 'nikah-planner',
        builder: (_, __) => const BiayaNikahPlannerPage(),
      ),
      GoRoute(
        path: '/kuliah-planner',
        name: 'kuliah-planner',
        builder: (_, __) => const BiayaKuliahPlannerPage(),
      ),
      GoRoute(
        path: '/wisata-planner',
        name: 'wisata-planner',
        builder: (_, __) => const TabunganWisataPage(),
      ),

      // ── Islamic Finance ──────────────────────────────────────────────────────
      GoRoute(
        path: '/zakat',
        name: 'zakat',
        builder: (_, __) => const ZakatPage(),
      ),
      GoRoute(
        path: '/mosque-donation',
        name: 'mosque-donation',
        builder: (_, __) => const MosqueDonationPage(),
      ),
      GoRoute(
        path: '/ramadan-mode',
        name: 'ramadan-mode',
        builder: (_, __) => const RamadanModePage(),
      ),
      GoRoute(
        path: '/hutang-jariyah',
        name: 'hutang-jariyah',
        builder: (_, __) => const HutangJariyahPage(),
      ),

      // ── Notes ─────────────────────────────────────────────────────────────────
      GoRoute(
        path: '/notes',
        name: 'notes',
        builder: (_, __) => const NotesPage(),
      ),
      GoRoute(
        path: '/note-detail',
        name: 'note-detail',
        builder: (_, state) => NoteDetailPage(note: state.extra as NoteModel?),
      ),

      // ── Social & Emergency ────────────────────────────────────────────────────
      GoRoute(
        path: '/challenge',
        name: 'challenge',
        builder: (_, __) => const ChallengePage(),
      ),
      GoRoute(
        path: '/nabung-bersama',
        name: 'nabung-bersama',
        builder: (_, __) => const NabungBersamaPage(),
      ),
      GoRoute(
        path: '/brankas-finansial',
        name: 'brankas-finansial',
        builder: (_, __) => const BrankasFinansialPage(),
      ),
      GoRoute(
        path: '/kontak-darurat',
        name: 'kontak-darurat',
        builder: (_, __) => const KontakDaruratFinansialPage(),
      ),

      // ── Shopping ─────────────────────────────────────────────────────────────
      GoRoute(
        path: '/shopping',
        name: 'shopping',
        builder: (_, __) => const ShoppingListPage(),
      ),
    ],
  );
});
