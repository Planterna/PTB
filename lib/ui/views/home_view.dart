import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

import 'package:flutter/gestures.dart';
import 'package:styled_widget/styled_widget.dart';

import 'settings_view.dart';
import 'payments_view.dart';
import '../widgets/account_card_widget.dart';
import '../widgets/transaction_item_widget.dart';
import '../widgets/bottom_nav_bar_widget.dart';
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
    // MVVM: instanciamos el ViewModel
    final remoteDataSource = RemoteFinanceDataSource();
    final repository = FinanceRepository(remoteDataSource);
    // Para el backend usamos el id del usuario en vez del email, o el token se encarga de esto.
    _viewModel = HomeViewModel(repository: repository, userId: widget.user.id);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Widget _buildDashboard() {
    return SafeArea(
      child: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (_viewModel.errorMessage != null) {
            return Center(
              child: Text(_viewModel.errorMessage!)
                  .textColor(AppColors.danger)
                  .fontSize(16),
            );
          }

          

          return SingleChildScrollView(
            child:
                <Widget>[
                      const SizedBox(height: 24),

                      // Título de Bienvenida dinámico
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
                            scrollBehavior: ScrollConfiguration.of(context)
                                .copyWith(
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                ),
                                child: AccountCardWidget(account: account),
                              );
                            },
                          ),
                        )
                      else
                        const Text('No tienes cuentas registradas.')
                            .textColor(AppColors.textMuted)
                            .alignment(Alignment.center)
                            .padding(vertical: 32),

                      const SizedBox(height: 16),

                      // Indicadores de carrusel (Puntos dinámicos)
                      if (_viewModel.accounts.length > 1)
                        Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(
                                _viewModel.accounts.length,
                                (index) {
                                  return GestureDetector(
                                    onTap: () {
                                      _pageController.animateToPage(
                                        index,
                                        duration: const Duration(
                                          milliseconds: 400,
                                        ),
                                        curve: Curves.easeInOut,
                                      );
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeOut,
                                      width: _currentCardIndex == index
                                          ? 16
                                          : 8,
                                      height: 8,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
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
                            )
                            .padding(vertical: 8, horizontal: 16)
                            .decorated(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                            )
                            .alignment(Alignment.center),

                      const SizedBox(height: 16),

                      // Botón para crear cuenta corriente (Oculto si ya tiene una)
                      if (!_viewModel.accounts.any(
                        (acc) => acc.tipoCuenta == 'corriente',
                      ))
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF14171D,
                            ), // Fondo oscuro sutil
                            foregroundColor: const Color(
                              0xFFCFEAFF,
                            ), // Color primary para el texto
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: const BorderSide(
                                color: AppColors.primary,
                                width: 1,
                              ), // Borde primary
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
                                    content: Text(
                                      '¡Cuenta corriente creada con éxito!',
                                    ),
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
                        ).alignment(Alignment.center),

                      const SizedBox(height: 32),

                      // Sección Movimientos Recientes con Filtro Desplegable
                      <Widget>[
                        const Text('Movimientos Recientes')
                            .textColor(AppColors.textPrimary)
                            .fontSize(20)
                            .fontWeight(FontWeight.bold)
                            .expanded(),

                        // Menú desplegable para el filtro
                        Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            border: Border.all(color: AppColors.surface),
                            borderRadius: BorderRadius.circular(14),
                          ),
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
                                  })
                                  .toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  _viewModel.setFilter(newValue);
                                }
                              },
                            ),
                          ),
                        ),
                      ].toRow(),

                      const SizedBox(height: 24),

                      // Generación dinámica de la lista de movimientos
                      if (_viewModel.transactions.isEmpty)
                        const Text('Sin movimientos')
                            .textColor(AppColors.textMuted)
                            .padding(vertical: 32)
                            .alignment(Alignment.center)
                      else if (_viewModel.filteredTransactions.isEmpty)
                        const Text('No hay movimientos para este filtro.')
                            .textColor(AppColors.textMuted)
                            .padding(vertical: 32)
                            .alignment(Alignment.center)
                      else
                        ..._viewModel.filteredTransactions.map(
                          (t) => TransactionItemWidget(
                            date: t.date,
                            name: t.name,
                            value: t.value,
                            type: t.type,
                          ),
                        ),
                    ]
                    .toColumn(crossAxisAlignment: CrossAxisAlignment.start)
                    .padding(horizontal: 24),
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
