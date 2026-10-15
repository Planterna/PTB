import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

import 'package:flutter/gestures.dart';
import 'package:styled_widget/styled_widget.dart';

import 'settings_view.dart';
import 'payments_view.dart';
import '../widgets/account_card_widget.dart';
import '../widgets/transaction_item_widget.dart';
import '../widgets/bottom_nav_bar_widget.dart';
import '../widgets/glass_container.dart';
import '../../data/models/user_model.dart';
import '../../data/datasources/remote/remote_finance_datasource.dart';
import '../../data/repositories/finance_repository.dart';
import '../viewmodels/home_viewmodel.dart';

class HomeView extends StatefulWidget {
  final UserModel user;

  const HomeView({super.key, required this.user});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;
  int _currentCardIndex = 0;

  late HomeViewModel _viewModel;
  final PageController _pageController = PageController(viewportFraction: 0.95);

  @override
  void initState() {
    super.initState();
    final remoteDataSource = RemoteFinanceDataSource();
    final repository = FinanceRepository(remoteDataSource);
    _viewModel = HomeViewModel(repository: repository, userId: widget.user.id);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Widget _buildEmptyState({required String title, required String subtitle}) {
    return SliverToBoxAdapter(
      child: <Widget>[
        const Icon(
          Icons.receipt_long_outlined,
          size: 36,
          color: AppColors.textMuted,
        )
            .padding(all: 16)
            .decorated(color: AppColors.surface, shape: BoxShape.circle),
        const SizedBox(height: 14),
        Text(title)
            .textColor(AppColors.textPrimary)
            .fontSize(16)
            .bold()
            .textAlignment(TextAlign.center),
        const SizedBox(height: 6),
        Text(subtitle)
            .textColor(AppColors.textMuted)
            .fontSize(13)
            .textAlignment(TextAlign.center),
      ]
          .toColumn()
          .padding(vertical: 40.0, horizontal: 24.0),
    );
  }

  Widget _buildDashboard() {
    return SafeArea(
      child: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_viewModel.isLoading) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text(
                    'Cargando tus finanzas...',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          if (_viewModel.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.danger, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      _viewModel.errorMessage!,
                      style: const TextStyle(color: AppColors.danger, fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _viewModel.loadData,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final transactions = _viewModel.filteredTransactions;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),

                      // Título de Bienvenida
                      Text('Bienvenido ${widget.user.name}')
                          .textColor(AppColors.textPrimary)
                          .fontSize(28)
                          .fontWeight(FontWeight.bold)
                          .alignment(Alignment.center),

                      const SizedBox(height: 24),

                      // Carrusel de Cuentas
                      if (_viewModel.accounts.isNotEmpty)
                        SizedBox(
                          height: 220,
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: _viewModel.accounts.length,
                            physics: const BouncingScrollPhysics(),
                            scrollBehavior: ScrollConfiguration.of(context).copyWith(
                              dragDevices: {
                                PointerDeviceKind.touch,
                                PointerDeviceKind.mouse,
                                PointerDeviceKind.trackpad,
                              },
                            ),
                            onPageChanged: (index) {
                              setState(() {
                                _currentCardIndex = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              final account = _viewModel.accounts[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                child: AccountCardWidget(account: account),
                              );
                            },
                          ),
                        )
                      else
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 32.0),
                            child: Text(
                              'No tienes cuentas registradas.',
                              style: TextStyle(color: AppColors.textMuted),
                            ),
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Indicadores de carrusel con efecto vidrio esmerilado
                      if (_viewModel.accounts.length > 1)
                        Center(
                          child: GlassContainer(
                            borderRadius: BorderRadius.circular(14),
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(
                                _viewModel.accounts.length,
                                (index) {
                                  return GestureDetector(
                                    onTap: () {
                                      _pageController.animateToPage(
                                        index,
                                        duration: const Duration(milliseconds: 400),
                                        curve: Curves.easeInOut,
                                      );
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeOut,
                                      width: _currentCardIndex == index ? 16 : 8,
                                      height: 8,
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      decoration: BoxDecoration(
                                        color: _currentCardIndex == index
                                            ? AppColors.textPrimary
                                            : AppColors.textMuted,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Botón para crear cuenta corriente (Oculto si ya tiene una)
                      if (!_viewModel.hasCheckingAccount)
                        Center(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.surface,
                              foregroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: const BorderSide(
                                  color: AppColors.primary,
                                  width: 1,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 24,
                              ),
                            ),
                            onPressed: () async {
                              final error = await _viewModel.createAccount(
                                tipoCuenta: 'corriente',
                              );
                              if (context.mounted) {
                                if (error == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('¡Cuenta corriente creada con éxito!'),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(error),
                                      backgroundColor: AppColors.danger,
                                    ),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.add_circle_outline),
                            label: const Text(
                              'Crear Cuenta Corriente',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),

                      const SizedBox(height: 32),

                      // Sección Movimientos Recientes con Filtro Desplegable
                      Row(
                        children: [
                          const Text('Movimientos Recientes')
                              .textColor(AppColors.textPrimary)
                              .fontSize(20)
                              .bold()
                              .expanded(),

                          // Menú desplegable para el filtro con efecto vidrio esmerilado
                          GlassContainer(
                            borderRadius: BorderRadius.circular(14),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            height: 40,
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _viewModel.filterValue,
                                icon: const Icon(
                                  Icons.filter_list,
                                  color: AppColors.textMuted,
                                  size: 18,
                                ),
                                dropdownColor: AppColors.surface,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                ),
                                items: <String>['Todos', 'Ingresos', 'Egresos']
                                    .map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    _viewModel.setFilter(newValue);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // Lista de Movimientos implementada con ListView / SliverList
              if (_viewModel.transactions.isEmpty)
                _buildEmptyState(
                  title: 'Sin movimientos registrados',
                  subtitle: 'Tus transacciones y consumos aparecerán listados aquí.',
                )
              else if (transactions.isEmpty)
                _buildEmptyState(
                  title: 'No hay movimientos para este filtro',
                  subtitle: 'Intenta seleccionando otra categoría en el menú desplegable.',
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  sliver: SliverList.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final t = transactions[index];
                      return TransactionItemWidget(
                        key: ValueKey(t.id),
                        date: t.date,
                        name: t.name,
                        value: t.value,
                        type: t.type,
                        category: t.displayCategory,
                      );
                    },
                  ),
                ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
            ],
          );
        },
      ),
    );
  }

  // Selector de vista según la pestaña activa
  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return PaymentsView(viewModel: _viewModel);
      case 2:
        return SettingsView(user: widget.user);
      default:
        return _buildDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: BottomNavBarWidget(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      body: _buildBody(),
    );
  }
}
