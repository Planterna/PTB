import '../datasources/mock/mock_user_datasource.dart';
import '../models/user_model.dart';

class UserRepository {
  // Por ahora dependemos del datasource de Mock
  final MockUserDataSource _mockDataSource;

  // En el futuro, aquí inyectarás también tu RemoteDataSource (conexión a API MySQL)
  UserRepository(this._mockDataSource);

  Future<UserModel> getUserProfile() async {
    // Cuando conectes el backend, solo cambiarás esta línea para
    // usar tu remoteDataSource en lugar del mock. 
    // ¡El resto de tu app no notará el cambio!
    return await _mockDataSource.getUserProfile();
  }
}
