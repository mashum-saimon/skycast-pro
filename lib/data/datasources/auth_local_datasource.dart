import 'package:sqflite/sqflite.dart';
import '../../core/constants/app_constants.dart';
import '../../database/database_helper.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<UserModel> registerUser(String username, String password);
  Future<UserModel?> loginUser(String username, String password);
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final DatabaseHelper dbHelper;

  AuthLocalDataSourceImpl(this.dbHelper);

  @override
  Future<UserModel> registerUser(String username, String password) async {
    final db = await dbHelper.database;
    final user = UserModel(
      username: username,
      password: password,
      createdAt: DateTime.now(),
    );
    try {
      final id = await db.insert(
        AppConstants.tableUsers,
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return UserModel(
        id: id,
        username: user.username,
        password: user.password,
        createdAt: user.createdAt,
      );
    } catch (e) {
      if (e is DatabaseException && e.isUniqueConstraintError()) {
        throw Exception('Username already exists');
      }
      rethrow;
    }
  }

  @override
  Future<UserModel?> loginUser(String username, String password) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      AppConstants.tableUsers,
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }
}
