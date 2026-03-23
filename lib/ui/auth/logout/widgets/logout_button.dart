import 'package:diakron_collection_center/routing/routes.dart';
import 'package:diakron_collection_center/ui/auth/logout/view_models/logout_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LogoutButton extends StatefulWidget {
  const LogoutButton({super.key, required this.viewModel});

  final LogoutViewModel viewModel;

  @override
  State<LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<LogoutButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        widget.viewModel.logout.execute();
        context.go(Routes.login);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 5),
            persist: false,
            dismissDirection: DismissDirection.horizontal,
            content: Text('HICE LOGOUT'),
          ),
        );
      },
      icon: Icon(Icons.logout),
    );
  }
}
