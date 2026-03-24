import 'package:flutter_med_flow_user_app/models/login_model.dart';
import 'package:flutter_med_flow_user_app/models/user_model.dart';
import 'package:flutter_riverpod/legacy.dart';

final loginProvider = StateProvider<LoginModel>((ref) => LoginModel(data: {}));

final userProvider = StateProvider<UserModel>((ref) => UserModel(data: {}));