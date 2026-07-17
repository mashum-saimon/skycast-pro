import 'package:dartz/dartz.dart';
import '../../core/utils/failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, UserModel>> login(String username, String password) async {
    try {
      final user = await localDataSource.loginUser(username, password);
      if (user != null) {
        return Right(user);
      } else {
        return const Left(CacheFailure('Invalid username or password'));
      }
    } catch (e) {
      return const Left(CacheFailure('Failed to login'));
    }
  }

  @override
  Future<Either<Failure, UserModel>> register(String username, String password) async {
    try {
      final user = await localDataSource.registerUser(username, password);
      return Right(user);
    } catch (e) {
      return Left(CacheFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
