import 'package:diakron_collection_center/data/repositories/auth/auth_repository.dart';
import 'package:diakron_collection_center/data/repositories/user/user_repository.dart';
import 'package:diakron_collection_center/ui/auth/logout/view_models/logout_viewmodel.dart';
import 'package:diakron_collection_center/ui/auth/logout/widgets/logout_button.dart';
import 'package:diakron_collection_center/ui/core/themes/colors.dart';
import 'package:diakron_collection_center/ui/home/view_models/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.viewModel});

  final HomeViewModel viewModel;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      
      // AppBar simple para poder volver atrás o cambiar tema si quisieras
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Puntos
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.confirmation_number,
                        size: 24,
                        
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "1,195",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          
                        ),
                      ),
                    ],
                  ),

                  LogoutButton(
                    viewModel: LogoutViewModel(
                      authRepository: context.read<AuthRepository>(),
                      userRepository: context.read<UserRepository>() 
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // BANNER (Siempre verde, el texto es blanco, no necesita cambios)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.greenDiakron1,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 100,
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_3,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Expanded(
                      child: Text(
                        "“Consigue grandes recompensas a la vez que ayudas al planeta”",
                        style: TextStyle(
                          color: Colors.white, // Siempre blanco sobre verde
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Text(
                "Tiendas populares",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    3,
                    (index) => _buildStoreCard(context),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              Text(
                "Nuestras recomendaciones",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    3,
                    (index) => _buildStoreCard(context),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,

        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          // Start QR Scanner
          // if (index == 2) {
          //   Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //       builder: (context) => const MobileScannerScreen(),
          //     ),
          //   );

          //   // This version can return a value instead of void and can handle rootNavigator:
          //   // Navigator.of(context).push(
          //   //   MaterialPageRoute<void>(
          //   //     builder: (context) => const MobileScannerScreen(),
          //   //   ),
          //   // );
          // }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: "Inicio",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined),
            label: "Actividad",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner, size: 30),
            label: "Escaner",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: "Tiendas",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Perfil",
          ),
        ],
      ),
    );
  }

  Widget _buildStoreCard(BuildContext context) {
    // Usamos colores fijos para la tarjeta interna (naranja suave)
    // porque es parte de la "Marca" de la tienda, no del tema de la app.
    final theme = Theme.of(context);

    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 15),
      child: Column(
        children: [
          Container(
            height: 120,
            width: 130,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE0B2),
              borderRadius: BorderRadius.circular(15),
              // Borde sutil para que se vea bien en fondo negro
              border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.storefront, color: Colors.orange, size: 40),
                SizedBox(height: 5),
                Text(
                  "DOÑA AGUA\n& DON CHILE",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Doña Agua &\nDon Chile",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              // Color dinámico para el texto externo
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }
}
