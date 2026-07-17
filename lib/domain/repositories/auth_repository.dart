import 'package:dartz/dartz.dart';
import '../../core/utils/failure.dart';
import '../../data/models/user_model.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserModel>> register(String username, String password);
  Future<Either<Failure, UserModel>> login(String username, String password);
}
