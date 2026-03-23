import 'package:diakron_collection_center/l10n/app_localizations.dart';
import 'package:diakron_collection_center/routing/routes.dart';
import 'package:diakron_collection_center/ui/auth/sigunp/view_models/signup_viewmodel.dart';
import 'package:diakron_collection_center/ui/core/themes/app_strings.dart';
import 'package:diakron_collection_center/ui/core/themes/dimens.dart';
import 'package:diakron_collection_center/ui/core/ui/form_button.dart';
import 'package:diakron_collection_center/ui/core/ui/input_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key, required this.viewModel});

  final SignupViewmodel viewModel;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Controllers
  final TextEditingController _name = TextEditingController(
    text: 'UserTestName',
  );
  final TextEditingController _surnames = TextEditingController(
    text: 'UserTestSurname',
  );
  final TextEditingController _email = TextEditingController(
    text: 'adotal1484@gmail.com',
  );
  final TextEditingController _phoneNumber = TextEditingController(
    text: '1234567890',
  );
  final TextEditingController _password = TextEditingController(
    text: '123456789',
  );
  final TextEditingController _confirmPassword = TextEditingController(
    text: '123456789',
  );

  @override
  void initState() {
    super.initState();
    widget.viewModel.signup.addListener(_onSignUpResult);
  }

  @override
  void didUpdateWidget(covariant SignupScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.viewModel.signup.removeListener(_onSignUpResult);
    widget.viewModel.signup.addListener(_onSignUpResult);
  }

  @override
  void dispose() {
    widget.viewModel.signup.removeListener(_onSignUpResult);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF387600), // El verde exacto
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            // Aquí puedes usar un Image.asset si tienes el logo
            const Icon(Icons.recycling, color: Colors.white, size: 30),
            const SizedBox(width: 10),
            const Text(
              AppStrings.diakron,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                fontSize: 24,
              ),
            ),
          ],
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(
              40,
            ), // Crea el efecto de curva hacia adentro
          ),
        ),
      ),

      body: ListView(
        children: [
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimens.formPaddingHorizontal,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppLocalizations.of(context)!.createAccount,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 30),

                InputText(
                  controller: _name,
                  hintText: AppLocalizations.of(context)!.names,
                ),
                const SizedBox(height: Dimens.paddingVertical),

                InputText(
                  controller: _surnames,
                  hintText: AppLocalizations.of(context)!.surnames,
                ),
                const SizedBox(height: Dimens.paddingVertical),

                // Campo Email
                InputText(
                  controller: _email,
                  hintText: AppLocalizations.of(context)!.email,
                ),
                const SizedBox(height: Dimens.paddingVertical),

                InputText(
                  controller: _phoneNumber,
                  hintText: AppLocalizations.of(context)!.phoneNumber,
                ),
                const SizedBox(height: Dimens.paddingVertical),

                // Campo Contraseña
                InputText(
                  controller: _password,
                  hintText: AppLocalizations.of(context)!.password,
                  obscureText: true,
                ),
                const SizedBox(height: Dimens.paddingVertical),
                // Field confirm password
                InputText(
                  controller: _confirmPassword,
                  hintText: AppLocalizations.of(context)!.confirmPassword,
                  obscureText: true,
                ),

                const SizedBox(height: 35),

                // Button for signing up
                FormButton(
                  text: AppLocalizations.of(context)!.signUp,
                  onPressed: () {
                    widget.viewModel.signup.execute((
                      _name.value.text,
                      _surnames.value.text,                      
                      _email.value.text,
                      _phoneNumber.value.text,
                      _password.value.text,
                      _confirmPassword.value.text,
                    ));
                  },
                  listenable: widget.viewModel.signup,
                ),

                const SizedBox(height: Dimens.longPaddingVertical),

                GestureDetector(
                  onTap: () {
                    context.go(Routes.login);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.haveAnAccount,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.black54),
                      ),
                      SizedBox(width: 5),

                      Text(
                        AppLocalizations.of(context)!.loginExclamation,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: Dimens.paddingVertical),
                Text(
                  AppLocalizations.of(context)!.termsAndConditions,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: Dimens.paddingVertical),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onSignUpResult() {
    if (widget.viewModel.signup.completed) {
      widget.viewModel.signup.clearResult();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Usuario registrado!')));

      context.go(Routes.login);
    }

    if (widget.viewModel.signup.error) {
      final error = widget.viewModel.signup.result;
      widget.viewModel.signup.clearResult();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$error')));
    }
  }
}
