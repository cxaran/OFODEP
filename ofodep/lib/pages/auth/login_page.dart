import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ofodep/widgets/container_page.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Iniciar Sesión'),
        automaticallyImplyLeading: false,
      ),
      body: ContainerPage(
        child: ListView(
          children: [
            const SizedBox(height: 20),
            SupaEmailAuth(
              onSignInComplete: (response) {},
              onSignUpComplete: (AuthResponse response) {},
              localization: SupaEmailAuthLocalization(
                enterEmail: 'Ingresa tu correo electrónico',
                validEmailError:
                    'Por favor, ingresa una dirección de correo válida',
                enterPassword: 'Ingresa tu contraseña',
                passwordLengthError:
                    'Por favor, ingresa una contraseña de al menos 6 caracteres',
                signIn: 'Iniciar sesión',
                signUp: 'Registrarse',
                forgotPassword: '¿Olvidaste tu contraseña?',
                dontHaveAccount: '¿No tienes una cuenta? Regístrate',
                haveAccount: '¿Ya tienes una cuenta? Inicia sesión',
                sendPasswordReset:
                    'Enviar correo de restablecimiento de contraseña',
                passwordResetSent:
                    'Se ha enviado el correo para restablecer la contraseña',
                backToSignIn: 'Volver a iniciar sesión',
                unexpectedError: 'Ocurrió un error inesperado',
                requiredFieldError: 'Este campo es obligatorio',
              ),
              metadataFields: [
                MetaDataField(
                  prefixIcon: const Icon(Icons.person),
                  label: 'Nombre',
                  key: 'name',
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Por favor ingresa un nombre';
                    }
                    return null;
                  },
                ),
                MetaDataField(
                  prefixIcon: const Icon(Icons.phone),
                  label: 'Telefono',
                  key: 'phone',
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Por favor ingresa un número de teléfono';
                    }
                    return null;
                  },
                ),
                BooleanMetaDataField(
                  key: 'terms_agreement',
                  isRequired: true,
                  checkboxPosition: ListTileControlAffinity.leading,
                  richLabelSpans: [
                    const TextSpan(text: 'He leído y acepto los '),
                    TextSpan(
                      text: 'Términos y Condiciones',
                      style: const TextStyle(
                        color: Colors.blue,
                      ),
                      recognizer: TapGestureRecognizer()..onTap = () {},
                    ),
                  ],
                ),
              ],
            ),
            SupaSocialsAuth(
              socialProviders: [
                OAuthProvider.google,
              ],
              colored: true,
              redirectUrl:
                  kIsWeb ? null : 'io.supabase.flutter://reset-callback/',
              onSuccess: (Session response) {},
              onError: (error) {},
            ),
          ],
        ),
      ),
    );
  }
}
