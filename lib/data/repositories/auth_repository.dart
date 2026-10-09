import '../datasources/remote/remote_auth_datasource.dart';
import '../models/user_model.dart';

class AuthRepository {
  final RemoteAuthDataSource _remoteDataSource;

  AuthRepository(this._remoteDataSource);

  Future<UserModel> login(String email, String password) async {
    return await _remoteDataSource.login(email, password);
  }

  Future<void> register(String idCard, String name, String email, String password) async {
    return await _remoteDataSource.register(idCard, name, email, password);
  }
}
