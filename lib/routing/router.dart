// Routes manager
import 'package:diakron_collection_center/data/repositories/auth/auth_repository.dart';
import 'package:diakron_collection_center/data/repositories/user/user_repository.dart';
import 'package:diakron_collection_center/models/user/collection_center.dart';
import 'package:diakron_collection_center/routing/routes.dart';
import 'package:diakron_collection_center/ui/auth/forgot_password/view_models/forgot_password_viewmodel.dart';
import 'package:diakron_collection_center/ui/auth/forgot_password/widgets/forgot_password_screen.dart';
import 'package:diakron_collection_center/ui/auth/login/view_models/login_viewmodel.dart';
import 'package:diakron_collection_center/ui/auth/login/widgets/login_screen.dart';
import 'package:diakron_collection_center/ui/auth/reset_password/view_models/reset_password_viewmodel.dart';
import 'package:diakron_collection_center/ui/auth/reset_password/widgets/reset_password_screen.dart';
import 'package:diakron_collection_center/ui/auth/sigunp/view_models/signup_viewmodel.dart';
import 'package:diakron_collection_center/ui/auth/sigunp/widgets/signup_screen.dart';
import 'package:diakron_collection_center/ui/home/view_models/home_viewmodel.dart';
import 'package:diakron_collection_center/ui/home/widgets/home_screen.dart';
import 'package:diakron_collection_center/ui/upload_files/widgets/privacy_policy_screen.dart';
import 'package:diakron_collection_center/ui/upload_files/widgets/upload_files_pages.dart';
import 'package:diakron_collection_center/ui/upload_files/widgets/upload_files_shell.dart';
import 'package:diakron_collection_center/ui/wating_approval/widgets/waiting_approval_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

GoRouter router(AuthRepository authRepository, UserRepository userRepository) => GoRouter(
  initialLocation: Routes.login,
  debugLogDiagnostics: true, // TESTING
  refreshListenable: Listenable.merge([
   authRepository,
   userRepository,
  ]),
  redirect: _redirect,

  routes: [
    GoRoute(
      path: Routes.login,
      builder: (context, state) {
        final viewModel = LoginViewModel(
          authRepository: context.read<AuthRepository>(),
        );
        return LoginScreen(viewModel: viewModel);
      },
    ),
    GoRoute(
      path: Routes.home,
      builder: (context, state) {
        return HomeScreen(
          viewModel: HomeViewModel(
            authRepository: context.read<AuthRepository>(),
          ),
        );
      },
    ),
    GoRoute(
      path: Routes.forgotpassword,
      builder: (context, state) {
        final viewModel = ForgotPasswordViewmodel(
          authRepository: context.read<AuthRepository>(),
        );
        return ForgotPasswordScreen(viewModel: viewModel);
      },
    ),
    GoRoute(
      path: Routes.resetpassword,
      builder: (context, state) {
        final viewModel = ResetPasswordViewmodel(
          authRepository: context.read<AuthRepository>(),
        );
        return ResetPasswordScreen(viewModel: viewModel);
      },
    ),

    ShellRoute(
      builder: (context, state, child) {
        // Here are progress bar and button
        return UploadFilesShell(child: child);
      },
      routes: [
        GoRoute(
          path: Routes.uploadData,
          builder: (context, state) => const UploadFilesStep1Page(),
        ),
        GoRoute(
          path: Routes.uploadData2,
          builder: (context, state) => const UploadFilesStep2Page(),
        ),
        GoRoute(
          path: Routes.uploadData3,
          builder: (context, state) => const UploadFilesStep3Page(),
        ),
        GoRoute(
          path: Routes.privacyPolicy,
          builder: (context, state) => const PrivacyPolicyScreen(),
        ),
      ],
    ),
    GoRoute(
      path: Routes.signup,
      builder: (context, state) {
        final viewModel = SignupViewModel(
          authRepository: context.read<AuthRepository>(),
        );
        return SignupScreen(viewModel: viewModel);
      },
    ),
    GoRoute(
      path: Routes.waitingApproval,
      builder: (context, state) {
        // final viewModel = SignupViewModel(
        //   authRepository: context.read<AuthRepository>(),
        // );
        return WaitingApprovalPage();
      },
    ),
  ],
);

Future<String?> _redirect(BuildContext context, GoRouterState state) async {
  final userRepo = context.read<UserRepository>();
  final authRepo = context.read<AuthRepository>();
  final bool loggedIn = authRepo.isAuthenticated;

  // // Locations
  final bool isAtLogin = state.matchedLocation == Routes.login;
  final bool isAtReset = state.matchedLocation == Routes.resetpassword;
  final bool isAtForgot = state.matchedLocation == Routes.forgotpassword;
  final bool isAtSignup = state.matchedLocation == Routes.signup;

  // 1. HIGHEST PRIORITY: Password Recovery
  // If Supabase tells us we are in recovery mode, force the reset page.
  if (authRepo.isRecoveringPassword) {
    return isAtReset ? null : Routes.resetpassword;
  }

  // 2. If not logged in, and not on an "Auth" page (login, signup, forgot), go to Login
  if (!loggedIn) {
    if (isAtLogin || isAtForgot || isAtSignup || isAtReset) {
      return null;
    }
    return Routes.login;
  }

  //final ValidationStatus validationStatus = userRepo.validationStatus!;
  final validationStatus = await userRepo.getValidationStatus(authRepo.userId!);

  final bool atUploadData = state.matchedLocation.startsWith(
    Routes.uploadDataRoot,
  );

  switch (validationStatus) {
    case ValidationStatus.approved:
      return Routes.home;
    case ValidationStatus.uploading:
      // If not already in a uploading proccess redirect to it
      if (!atUploadData) {
        return Routes.uploadData;
      }
    case ValidationStatus.pending:
      return Routes.waitingApproval;
    case ValidationStatus.denied:
    // return Routes.denied;
  }
  return null;
}