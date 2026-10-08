import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:styled_widget/styled_widget.dart';
import 'settings_view.dart';
import '../widgets/bank_card_widget.dart';
import '../widgets/transaction_item_widget.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;
  int _currentCardIndex = 0; 
  String _filterValue = 'Todos'; // Estado para el dropdown ('Todos', 'Ingresos', 'Egresos')

  // Lista simulada de las tarjetas del usuario
  final List<Map<String, dynamic>> _myCards = [
    {'name': 'Cuenta de ahorro', 'number': '0123456789', 'balance': 1000.00},
    {'name': 'Tarjeta de Crédito', 'number': '**** **** **** 4567', 'balance': -350.50},
  ];

  final PageController _pageController = PageController(viewportFraction: 0.95);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Lista simulada de transacciones para mostrar la reutilización y el filtro
  final List<Map<String, dynamic>> _transactions = [
    {
      'date': 'Viernes, 2 Octubre',
      'name': 'Juan Miguel Alcivar Ramos',
      'value': 120.00,
      'type': TransactionType.transfer, // Transferencia de persona a persona
    },
    {
      'date': 'Sábado, 3 Octubre',
      'name': 'Lucia Dana Alvarado Díaz',
      'value': -600.00,
      'type': TransactionType.transfer,
    },
    {
      'date': 'Domingo, 4 Octubre',
      'name': 'Supermaxi',
      'value': -45.50,
      'type': TransactionType.purchase, // Compra a empresa
    },
    {
      'date': 'Lunes, 5 Octubre',
      'name': 'Steam App',
      'value': -30.00,
      'type': TransactionType.subscription, // Suscripción / Servicio
    },
    {
      'date': 'Martes, 6 Octubre',
      'name': 'Nómina Empresa S.A.',
      'value': 1500.00,
      'type': TransactionType.deposit, // Depósito / Sueldo
    },
  ];

  Widget _buildDashboard() {
    final filteredTransactions = _transactions.where((t) {
      if (_filterValue == 'Ingresos') return t['value'] >= 0;
      if (_filterValue == 'Egresos') return t['value'] < 0;
      return true;
    }).toList();

    return SafeArea(
      child: SingleChildScrollView(
        child: <Widget>[
          const SizedBox(height: 24),

          // Título de Bienvenida
          const Text('Bienvenido Usuario')
              .textColor(const Color(0xFFFFFFFF))
              .fontSize(28)
              .fontWeight(FontWeight.bold)
              .alignment(Alignment.center),

          const SizedBox(height: 24),

          // Carrusel de Tarjetas
          SizedBox(
            height: 220, 
            child: PageView.builder(
              controller: _pageController,
              itemCount: _myCards.length,
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
                final card = _myCards[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: BankCardWidget(
                    cardName: card['name'],
                    cardNumber: card['number'],
                    balance: card['balance'],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Indicadores de carrusel (Puntos dinámicos)
          if (_myCards.length > 1)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_myCards.length, (index) {
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
          if (filteredTransactions.isEmpty)
            const Text('No hay movimientos para este filtro.')
                .textColor(const Color(0xFFA8AEB8))
                .padding(vertical: 32)
                .alignment(Alignment.center)
          else
            ...filteredTransactions.map((t) => TransactionItemWidget(
                  date: t['date'],
                  name: t['name'],
                  value: t['value'],
                  type: t['type'],
                )),
                
        ].toColumn(crossAxisAlignment: CrossAxisAlignment.start).padding(horizontal: 24),
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
