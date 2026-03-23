import 'package:diakron_collection_center/routing/routes.dart';
import 'package:diakron_collection_center/ui/home/view_models/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.viewModel});

  final HomeViewModel viewModel;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.logout.addListener(_onLogoutResult);
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.viewModel.logout.removeListener(_onLogoutResult);
    widget.viewModel.logout.addListener(_onLogoutResult);
  }

  @override
  void dispose() {
    widget.viewModel.logout.removeListener(_onLogoutResult);
    super.dispose();
  }

  void _onLogoutResult() {
    if (widget.viewModel.logout.completed) {
      widget.viewModel.logout.clearResult();
      // Navigate back to the login screen
      context.go(Routes.login);
    }
    if (widget.viewModel.logout.error) {
      widget.viewModel.logout.clearResult();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error logging out. Please try again.')),
      );
    }
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diakron Dashboard'),
        actions: [
          // LOGOUT BUTTON
          ListenableBuilder(
            listenable: widget.viewModel.logout,
            builder: (context, _) {
              if (widget.viewModel.logout.running) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              
              return IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Logout',
                onPressed: () {
                  widget.viewModel.logout.execute();
                },
              );
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Welcome to the Admin Dashboard!'),
      ),
    );
  }
}
