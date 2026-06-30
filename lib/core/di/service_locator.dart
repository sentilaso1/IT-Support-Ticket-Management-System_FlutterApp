import 'package:sqflite/sqflite.dart';

import '../../features/auth/application/services/auth_service_impl.dart';
import '../../features/auth/application/services/i_auth_service.dart';
import '../../features/auth/data/datasources/auth_local_data_source_impl.dart';
import '../../features/auth/data/datasources/i_auth_local_data_source.dart';
import '../../features/auth/data/mappers/user_mapper.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/i_auth_repository.dart';
import '../../features/auth/presentation/viewmodels/login_view_model.dart';
import '../../features/tickets/data/datasources/i_ticket_local_data_source.dart';
import '../../features/tickets/data/datasources/ticket_local_data_source_impl.dart';
import '../../features/user_management/application/services/i_user_management_service.dart';
import '../../features/user_management/application/services/user_management_service_impl.dart';
import '../../features/user_management/data/datasources/i_user_local_data_source.dart';
import '../../features/user_management/data/datasources/user_local_data_source_impl.dart';
import '../../features/user_management/data/mappers/user_mapper.dart';
import '../../features/user_management/data/repositories/user_management_repository_impl.dart';
import '../../features/user_management/domain/repositories/i_user_management_repository.dart';
import '../../features/user_management/presentation/viewmodels/create_user_view_model.dart';
import '../../features/user_management/presentation/viewmodels/update_user_view_model.dart';
import '../../features/user_management/presentation/viewmodels/user_list_view_model.dart';
import '../database/app_database.dart';

class ServiceLocator {
  ServiceLocator._();

  static ITicketLocalDataSource? _ticketLocalDataSource;
  static IAuthLocalDataSource? _authLocalDataSource;
  static IAuthRepository? _authRepository;
  static IAuthService? _authService;
  static LoginViewModel? _loginViewModel;
  static IUserLocalDataSource? _userLocalDataSource;
  static IUserManagementRepository? _userManagementRepository;
  static IUserManagementService? _userManagementService;

  static Future<Database> get database {
    return AppDatabase.instance;
  }

  static Future<ITicketLocalDataSource> get ticketLocalDataSource async {
    return _ticketLocalDataSource ??= TicketLocalDataSourceImpl(await database);
  }

  static Future<IAuthLocalDataSource> get authLocalDataSource async {
    return _authLocalDataSource ??= AuthLocalDataSourceImpl(await database);
  }

  static Future<IAuthRepository> get authRepository async {
    return _authRepository ??= AuthRepositoryImpl(
      localDataSource: await authLocalDataSource,
      userMapper: const UserMapper(),
    );
  }

  static Future<IAuthService> get authService async {
    return _authService ??= AuthServiceImpl(await authRepository);
  }

  static Future<LoginViewModel> get loginViewModel async {
    return _loginViewModel ??= LoginViewModel(await authService);
  }

  static Future<IUserLocalDataSource> get userLocalDataSource async {
    return _userLocalDataSource ??= UserLocalDataSourceImpl(await database);
  }

  static Future<IUserManagementRepository> get userManagementRepository async {
    return _userManagementRepository ??= UserManagementRepositoryImpl(
      localDataSource: await userLocalDataSource,
      mapper: const UserManagementMapper(),
    );
  }

  static Future<IUserManagementService> get userManagementService async {
    return _userManagementService ??=
        UserManagementServiceImpl(await userManagementRepository);
  }

  static Future<UserListViewModel> get userListViewModel async {
    return UserListViewModel(await userManagementService);
  }

  static Future<CreateUserViewModel> get createUserViewModel async {
    return CreateUserViewModel(await userManagementService);
  }

  static Future<UpdateUserViewModel> get updateUserViewModel async {
    return UpdateUserViewModel(await userManagementService);
  }
}
