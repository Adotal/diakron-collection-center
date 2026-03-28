import 'package:diakron_collection_center/data/repositories/auth/auth_repository.dart';
import 'package:diakron_collection_center/data/repositories/user/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WaitingApprovalPage extends StatelessWidget {
  const WaitingApprovalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.hourglass_empty, size: 80, color: Colors.orange),
              const SizedBox(height: 24),
              const Text(
                "Esperando validación",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                "Un administrador revisará tu información pronto. Por favor, espera.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text("Recargar estado"),
                onPressed: () async {
                  final auth = context.read<AuthRepository>();
                  final userRepo = context.read<UserRepository>();
                  // Force a check to see if status changed to 'approved'
                  await userRepo.getValidationStatus(auth.userId!, forceRefresh: true);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}