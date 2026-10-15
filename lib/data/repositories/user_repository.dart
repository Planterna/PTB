import '../datasources/remote/remote_user_datasource.dart';
import '../models/user_model.dart';

class UserRepository {
  final RemoteUserDataSource _remoteDataSource;

  UserRepository(this._remoteDataSource);

  Future<UserModel> getUserProfile() async {
    return await _remoteDataSource.getUserProfile();
  }

  Future<UserModel> updateUserProfile({
    required String id,
    required String name,
    required String email,
  }) async {
    return await _remoteDataSource.updateUserProfile(
      id: id,
      name: name,
      email: email,
    );
  }
}
