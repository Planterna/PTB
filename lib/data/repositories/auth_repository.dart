import '../datasources/mock/mock_auth_datasource.dart';
import '../models/user_model.dart';

class AuthRepository {
  final MockAuthDataSource _mockDataSource;

  // En el futuro inyectarás aquí el RemoteDataSource
  AuthRepository(this._mockDataSource);

  Future<UserModel> login(String email, String password) async {
    return await _mockDataSource.login(email, password);
  }

  Future<UserModel> register(String idCard, String name, String email, String password) async {
    return await _mockDataSource.register(idCard, name, email, password);
  }
}
