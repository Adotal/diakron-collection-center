import 'package:diakron_collection_center/ui/core/themes/app_strings.dart';
import 'package:diakron_collection_center/ui/core/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomScreen extends StatelessWidget {
  const CustomScreen({super.key, required this.child,});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greenDiakron1, // El verde de Diakron
      body: Column(
        children: [
          // SECCIÓN SUPERIOR (AppBar Personalizada)
          SafeArea(
            bottom: false, // No padding abajo para que pegue con lo blanco
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 4,
              ),
              width: double.infinity,
              child: Row(
                children: [
                  // Back button
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      }
                    },
                  ),
                  const SizedBox(width: 30),
                  const Icon(Icons.recycling, color: Colors.white, size: 30),
                  const SizedBox(width: 10),
                  const Text(
                    AppStrings.appName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Cuerpo de la app)
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(
                    45.0,
                  ), // Curva pronunciada de tu imagen
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(45.0),
                ),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
