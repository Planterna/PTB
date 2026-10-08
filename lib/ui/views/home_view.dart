import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:styled_widget/styled_widget.dart';
import 'settings_view.dart';
import '../widgets/bank_card_widget.dart';
import '../widgets/transaction_item_widget.dart';
import '../../data/models/user_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/datasources/mock/mock_finance_datasource.dart';
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
  String _filterValue = 'Todos'; 

  late HomeViewModel _viewModel;
  final PageController _pageController = PageController(viewportFraction: 0.95);

  @override
  void initState() {
    super.initState();
    // MVVM: instanciamos el ViewModel
    final mockDataSource = MockFinanceDataSource();
    final repository = FinanceRepository(mockDataSource);
    // Usamos el email como ID para este mock
    _viewModel = HomeViewModel(repository: repository, userId: widget.user.email);
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
              child: CircularProgressIndicator(color: Color(0xFFCFEAFF)),
            );
          }

          if (_viewModel.errorMessage != null) {
            return Center(
              child: Text(_viewModel.errorMessage!)
                  .textColor(const Color(0xFFFF8A8A))
                  .fontSize(16),
            );
          }

          final filteredTransactions = _viewModel.transactions.where((t) {
            if (_filterValue == 'Ingresos') return t.value >= 0;
            if (_filterValue == 'Egresos') return t.value < 0;
            return true;
          }).toList();

          return SingleChildScrollView(
            child: <Widget>[
              const SizedBox(height: 24),

              // Título de Bienvenida dinámico
              Text('Bienvenido ${widget.user.name}')
                  .textColor(const Color(0xFFFFFFFF))
                  .fontSize(28)
                  .fontWeight(FontWeight.bold)
                  .alignment(Alignment.center),

              const SizedBox(height: 24),

              // Carrusel de Tarjetas
              if (_viewModel.cards.isNotEmpty)
                SizedBox(
                  height: 220, 
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _viewModel.cards.length,
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
                      final card = _viewModel.cards[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: BankCardWidget(
                          cardName: card.cardName,
                          cardNumber: card.cardNumber,
                          balance: card.balance,
                        ),
                      );
                    },
                  ),
                )
              else
                const Text('No tienes tarjetas registradas.')
                    .textColor(const Color(0xFFA8AEB8))
                    .alignment(Alignment.center)
                    .padding(vertical: 32),

              const SizedBox(height: 16),

              // Indicadores de carrusel (Puntos dinámicos)
              if (_viewModel.cards.length > 1)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(_viewModel.cards.length, (index) {
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
                          color: _currentCardIndex == index ? const Color(0xFFFFFFFF) : const Color(0xFFA8AEB8),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    );
                  }),
                )
                    .padding(vertical: 8, horizontal: 16)
                    .decorated(
                      color: const Color(0xFF14171D),
                      borderRadius: BorderRadius.circular(14),
                    )
                    .alignment(Alignment.center),

              const SizedBox(height: 32),

              // Sección Movimientos Recientes con Filtro Desplegable
              <Widget>[
                const Text('Movimientos Recientes')
                    .textColor(const Color(0xFFFFFFFF))
                    .fontSize(20)
                    .fontWeight(FontWeight.bold)
                    .expanded(),
                    
                // Menú desplegable para el filtro
                Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF14171D),
                    border: Border.all(color: const Color(0xFF14171D)),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _filterValue,
                      icon: const Icon(Icons.filter_list, color: Color(0xFFA8AEB8), size: 18),
                      dropdownColor: const Color(0xFF14171D),
                      style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 14),
                      items: <String>['Todos', 'Ingresos', 'Egresos']
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _filterValue = newValue;
                          });
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
                    .textColor(const Color(0xFFA8AEB8))
                    .padding(vertical: 32)
                    .alignment(Alignment.center)
              else if (filteredTransactions.isEmpty)
                const Text('No hay movimientos para este filtro.')
                    .textColor(const Color(0xFFA8AEB8))
                    .padding(vertical: 32)
                    .alignment(Alignment.center)
              else
                ...filteredTransactions.map((t) => TransactionItemWidget(
                      date: t.date,
                      name: t.name,
                      value: t.value,
                      type: t.type,
                    )),
                    
            ].toColumn(crossAxisAlignment: CrossAxisAlignment.start).padding(horizontal: 24),
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
        return const Center(
          child: Text(
            'Pantalla de Pagos (En construcción)',
            style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 16),
          ),
        );
      case 2:
        return const SettingsView();
      default:
        return _buildDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF14171D),
        selectedItemColor: const Color(0xFFCFEAFF),
        unselectedItemColor: const Color(0xFFA8AEB8),
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.payments_outlined), label: 'Pagos'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Configuración'),
        ],
      ),
      body: _buildBody(),
    );
  }
}
