import 'package:flutter/material.dart';
import '../viewmodels/user_viewmodel.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/datasources/mock/mock_user_datasource.dart';

class UserView extends StatefulWidget {
  const UserView({Key? key}) : super(key: key);

  @override
  State<UserView> createState() => _UserViewState();
}

class _UserViewState extends State<UserView> {
  late UserViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    
    // Inyección de dependencias manual (para la prueba).
    // Normalmente usarías paquetes como 'get_it' o 'provider' para esto.
    final mockDataSource = MockUserDataSource();
    final repository = UserRepository(mockDataSource);
    _viewModel = UserViewModel(repository);

    // Cargamos los datos al inicializar la pantalla
    _viewModel.loadUserProfile();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil (MVVM Mock)'),
      ),
      // ListenableBuilder reconstruye la UI cada vez que se llama a notifyListeners() en el ViewModel
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, child) {
          
          // Estado de carga
          if (_viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Estado de error
          if (_viewModel.errorMessage != null) {
            return Center(child: Text(_viewModel.errorMessage!));
          }

          // Estado vacío
          final user = _viewModel.user;
          if (user == null) {
            return const Center(child: Text('No se encontraron datos del usuario.'));
          }

          // Estado con datos
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.account_circle, size: 120, color: Colors.blueAccent),
                const SizedBox(height: 20),
                Text(
                  user.name, 
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 8),
                Text(
                  user.email, 
                  style: const TextStyle(fontSize: 16, color: Colors.grey)
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () {
                    // Podemos volver a cargar para ver el loader en acción
                    _viewModel.loadUserProfile();
                  }, 
                  icon: const Icon(Icons.refresh), 
                  label: const Text("Recargar Datos")
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
