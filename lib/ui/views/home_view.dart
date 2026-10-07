import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'settings_view.dart';
import '../widgets/bank_card_widget.dart';
import '../widgets/transaction_item_widget.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;
  int _currentCardIndex = 0; // Para rastrear la tarjeta actual del carrusel

  // Lista simulada de las tarjetas del usuario
  final List<Map<String, dynamic>> _myCards = [
    {
      'name': 'Cuenta de ahorro',
      'number': '0123456789',
      'balance': 1000.00,
    },
    {
      'name': 'Tarjeta de Crédito',
      'number': '**** **** **** 4567',
      'balance': -350.50, // Ejemplo de saldo deudor
    }
  ];

  // Cuerpo de la pestaña Inicio (Dashboard)
  Widget _buildDashboard() {
    return SafeArea(
      child: SingleChildScrollView(
        child: <Widget>[
          const SizedBox(height: 20),
          
          // Título de Bienvenida
          const Text('Bienvenido Usuario')
              .textColor(const Color(0xFFE3F2FD))
              .fontSize(28)
              .fontWeight(FontWeight.bold)
              .alignment(Alignment.center),
              
          const SizedBox(height: 24),
          
          // Carrusel de Tarjetas
          SizedBox(
            height: 210, // Altura fija para que el PageView funcione correctamente
            child: PageView.builder(
              itemCount: _myCards.length,
              onPageChanged: (index) {
                setState(() {
                  _currentCardIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final card = _myCards[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0), // Espaciado tenue
                  child: BankCardWidget(
                    cardName: card['name'],
                    cardNumber: card['number'],
                    balance: card['balance'],
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Indicadores de carrusel (Puntos dinámicos)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(_myCards.length, (index) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: _currentCardIndex == index ? Colors.black : Colors.grey,
                  shape: BoxShape.circle,
                ),
              );
            }),
          )
           .padding(vertical: 8, horizontal: 16)
           .decorated(
             color: const Color(0xFF333333),
             borderRadius: BorderRadius.circular(20),
           )
           .alignment(Alignment.center),
          
          const SizedBox(height: 30),
          
          // Sección Movimientos Recientes
          <Widget>[
            const Text('Movimientos Recientes')
                .textColor(const Color(0xFFA5E6D8))
                .fontSize(20)
                .fontWeight(FontWeight.bold)
                .expanded(),
            const Icon(Icons.filter_alt_outlined, color: Color(0xFFA5E6D8))
                .padding(all: 4)
                .decorated(
                  border: Border.all(color: const Color(0xFFA5E6D8)),
                  borderRadius: BorderRadius.circular(8),
                ),
          ].toRow(),
          
          const SizedBox(height: 20),
          
          // Lista de Movimientos usando Componente Reutilizable
          const TransactionItemWidget(
            date: 'Viernes, 2 Octubre',
            name: 'Juan Miguel Alcivar Ramos',
            value: 120.00,
            companyLogo: Icon(Icons.sync, color: Colors.pinkAccent), 
          ),
          
          TransactionItemWidget(
            date: 'Sabado, 3 Octubre',
            name: 'Lucia Dana Alvarado Díaz',
            value: -600.00,
            companyLogo: Container(
              width: 24, height: 24, 
              color: Colors.yellow, 
              child: const Center(child: Icon(Icons.square, size: 10, color: Colors.blueAccent))
            ),
          ),
          
          const TransactionItemWidget(
            date: 'Domingo, 4 Octubre',
            name: 'Steam App',
            value: -30.00,
            companyLogo: Icon(Icons.gamepad, color: Colors.white),
          ),
          
        ]
            .toColumn(crossAxisAlignment: CrossAxisAlignment.start)
            .padding(horizontal: 20),
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
          child: Text('Pantalla de Pagos (En construcción)', style: TextStyle(color: Colors.white, fontSize: 18))
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
      backgroundColor: Colors.black,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF2C2C2C),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payments_outlined),
            label: 'Pagos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configuración',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
}
