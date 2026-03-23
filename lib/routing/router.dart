// Routes manager
import 'package:diakron_collection_center/data/repositories/auth/auth_repository.dart';
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
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

GoRouter router(AuthRepository authRepository) => GoRouter(
  initialLocation: Routes.home,
  debugLogDiagnostics: true, // TESTING
  refreshListenable: authRepository,
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
          authRepository: context.read<AuthRepository>()
        );
        return ResetPasswordScreen(viewModel: viewModel);
      },
    ),
    GoRoute(
      path: Routes.signup,
      builder: (context, state) {
        final viewModel = SignupViewmodel(
          authRepository: context.read<AuthRepository>(),
        );
        return SignupScreen(viewModel: viewModel);
      },
    ),
  ],
);

Future<String?> _redirect(BuildContext context, GoRouterState state) async {
  final authRepo = context.read<AuthRepository>();
  final bool loggedIn = authRepo.isAuthenticated;
  
  // Locations
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

  // 3. If logged in but trying to hit the login or signup page, go Home
  // if (loggedIn && (isAtLogin || isAtSignup)) {
  //   return Routes.home;
  // }

  return null;
}

// Future<String?> _redirect(BuildContext context, GoRouterState state) async {
//   // if the user is not logged in, they need to login
//   final bool loggedIn = context.read<AuthRepository>().isAuthenticated;
//   final bool loggingIn = (state.matchedLocation == Routes.login);

//   // Deep Link for Password Reset
//   // Supabase sends the user to /callback by default;
//   // check if the incoming path matches your reset route.
//   final bool isResetting = (state.matchedLocation == Routes.resetpassword);

//   if (context.read<AuthRepository>().isRecoveringPassword) {
//     return Routes.resetpassword; // Push them to the reset screen
//   }

//   // If not logged in and its not already on login/reset page, force login
//   // if (!loggedIn && loggingIn && !isResetting) {
//   //   return Routes.login;
//   // }

//   // If logged in and trying to go to login page, send home
//   // if (loggedIn && loggingIn && !isResetting) {
//   //   return Routes.home;
//   // }

//   // No need to redirect at all
//   return null;
// }
