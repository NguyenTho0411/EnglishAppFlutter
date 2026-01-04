import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../features/authentication/presentation/blocs/auth/auth_bloc.dart';
import '../../../../features/authentication/presentation/pages/authentication_page.dart';
import '../../../features/user/user_cart/presentation/cubits/cart/cart_cubit.dart';
import '../../../features/user/user_cart/presentation/cubits/cart_bag/cart_bag_cubit.dart';
import '../../../features/user/user_profile/presentation/cubits/favourite/word_favourite_cubit.dart';
import '../../../features/user/user_profile/presentation/cubits/known/known_word_cubit.dart';
import '../../../features/user/user_profile/presentation/cubits/user_data/user_data_cubit.dart';
import '../../../features/user/user_profile/domain/entities/user_entity.dart';
import '../../../features/user/user_profile/domain/repositories/user_repository.dart';
import '../../../injection_container.dart';
import '../../managers/shared_preferences.dart';
import '../../utils/util_functions.dart';
import '../../widgets/status_bar.dart';
import '../main/main_page.dart';
import '../setting/cubits/schedule_notification/schedule_notification_cubit.dart';

class EntryPage extends StatefulWidget {
  const EntryPage({super.key});

  @override
  State<EntryPage> createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _rescheduleNotification();
    });
  }

  Future<void> _rescheduleNotification() async {
    final scheduleTime = sl<SharedPrefManager>().getScheduleNotiTime;
    if (scheduleTime != null) {
      await context
          .read<ScheduleNotificationCubit>()
          .setScheduleNotification(scheduleTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StatusBar(
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (_, state) {},
        buildWhen: (previous, current) => previous != current,
        builder: (context, state) {
          if (state is AuthenticatedState) {
            return const AuthenticatedEntryPage(child: MainPage());
          } else {
            context.read<UserDataCubit>().cancelDataStream();
            return const AuthenticationPage();
          }
        },
      ),
    );
  }
}

class AuthenticatedEntryPage extends StatefulWidget {
  final Widget child;
  const AuthenticatedEntryPage({super.key, required this.child});

  @override
  State<AuthenticatedEntryPage> createState() => _AuthenticatedEntryPageState();
}

class _AuthenticatedEntryPageState extends State<AuthenticatedEntryPage> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final authState = context.read<AuthBloc>().state;
    final uid = authState.user?.uid;
    if (uid != null) {
      // Ensure user document exists
      await _ensureUserDocumentExists(uid, authState.user!);
      
      context.read<UserDataCubit>().initDataStream(uid);
      context.read<CartBagCubit>().getCartBag();
      
      // Auto-create cart if not exists (getCart now handles this)
      await context.read<CartCubit>().getCart(uid);
      
      // Sync favourites and knowns (these read from user document)
      await Future.wait([
        context.read<WordFavouriteCubit>().syncFavourites(uid),
        context.read<KnownWordCubit>().syncKnowns(uid),
      ]);
    }
  }

  Future<void> _ensureUserDocumentExists(String uid, User firebaseUser) async {
    try {
      final userRepository = sl<UserRepository>();
      
      // Create user entity from Firebase Auth data
      final userEntity = UserEntity(
        uid: uid,
        name: firebaseUser.displayName ?? UtilFunction.splitFirst(firebaseUser.email ?? '', '@'),
        email: firebaseUser.email ?? '',
        method: 'password', // Default for email/password auth
        avatar: firebaseUser.photoURL,
        phone: firebaseUser.phoneNumber,
        birthday: DateTime.now(),
        createdDate: firebaseUser.metadata.creationTime,
      );
      
      // Try to create user document (merge will not overwrite existing)
      await userRepository.addUserProfile(userEntity);
      print('✅ Ensured user document exists for $uid');
    } catch (e) {
      print('⚠️ Error ensuring user document: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
