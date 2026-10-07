import '../../models/user_model.dart';

class MockUserDataSource {
  // Simula una petición a una API que tarda 2 segundos en responder
  Future<UserModel> getUserProfile() async {
    await Future.delayed(const Duration(seconds: 2)); 
    
    // Devolvemos datos "quemados" (mock)
    return UserModel(
      id: '1',
      name: 'Usuario Prueba',
      email: 'prueba@prestigetrustbank.com',
    );
  }
}
