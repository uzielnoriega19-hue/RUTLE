import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:rutle_test/modulos/autenticacion/verificacion/verificacion_correo_controlador.dart';

class RegistroControlador {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Map<String, double>?> _obtenerCoordenadas(String direccionCompleta) async {
    try {
      final locations = await locationFromAddress(direccionCompleta);
      if (locations.isEmpty) return null;
      return {
        "lat": locations.first.latitude,
        "lng": locations.first.longitude,
      };
    } catch (e) {
      return null;
    }
  }

  Future<void> _manejarCorreoExistente(String email, String password) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = cred.user;

      if (user != null && !user.emailVerified) {
        await user.delete();
      }

      await _auth.signOut();
    } catch (_) {}
  }

  Future<String> registrarUsuario({
    required String email,
    required String password,
    required String confirmPassword,
    required String nombreUsuario,
    required String direccion,
    required String colonia,
    required int avatarId,
  }) async {
    try {
      if (email.trim().isEmpty) return 'Falta el correo';
      if (password.trim().isEmpty) return 'Falta la contraseña';
      if (confirmPassword.trim().isEmpty) return 'Confirma la contraseña';
      if (nombreUsuario.trim().isEmpty) return 'Falta el nombre de usuario';
      if (direccion.trim().isEmpty) return 'Falta la dirección';
      if (colonia.trim().isEmpty) return 'Falta la colonia';

      if ('@'.allMatches(email).length != 1) {
        return 'El correo debe tener exactamente un @';
      }

      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
      if (!emailRegex.hasMatch(email)) {
        return 'Formato de correo inválido';
      }

      nombreUsuario = nombreUsuario.trim().replaceAll(RegExp(r'\s+'), '');

      final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
      if (!usernameRegex.hasMatch(nombreUsuario)) {
        return 'El usuario solo puede tener letras, números y _';
      }

      if (password != confirmPassword) {
        return 'Las contraseñas no coinciden';
      }

      if (password.length < 6) {
        return 'La contraseña debe tener mínimo 6 caracteres';
      }

      await _manejarCorreoExistente(email.trim(), password.trim());

      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = cred.user;

      if (user == null) {
        return 'Error al crear el usuario';
      }

      // Dirección completa solo para geocoding
      final direccionParaGeo =
          "${direccion.trim()}, ${colonia.trim()}, Guadalajara, Jalisco, Mexico";

      // Dirección corta para mostrar al usuario
      final direccionCorta =
          "${direccion.trim()}, ${colonia.trim()}";

      final coords = await _obtenerCoordenadas(direccionParaGeo);

      await _db.collection('usuarios').doc(user.uid).set({
      "idUsuario": user.uid,
      "correo": email.trim(),
      "nombreUsuario": nombreUsuario,
      "direccion": direccion.trim(),
      "colonia": colonia.trim(),
      "direccionCompleta": direccionCorta,
      "avatarId": avatarId,
      "fotoUsuario":
          "https://api.dicebear.com/7.x/avataaars/png?seed=$avatarId",
      "fechaRegistro": FieldValue.serverTimestamp(),
      "lat": coords?["lat"],
      "lng": coords?["lng"],
      "rol": "usuario",
    });

      await user.sendEmailVerification();

      VerificacionCorreoControlador.setCredenciales(
        email.trim(),
        password.trim(),
      );

      await _auth.signOut();

      return "OK";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'Este correo ya está registrado';
      }
      if (e.code == 'invalid-email') {
        return 'Correo inválido';
      }
      if (e.code == 'weak-password') {
        return 'La contraseña es muy débil';
      }

      return 'Error Firebase: ${e.message}';
    } catch (e) {
      return 'Error inesperado: ${e.toString()}';
    }
  }
}