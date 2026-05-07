import 'package:flutter/material.dart';
import 'package:rutle_test/modulos/foros/pantallas/detalle_foro_pantalla.dart';
import 'package:rutle_test/modulos/foros/pantallas/nuevos_foros_pantalla.dart';
import 'package:rutle_test/modulos/recordatorios/pantallas/agregar_recordatorio_pantalla.dart';
import '../modulos/mapas/pantallas/seleccionar_dia_pantalla.dart';
import '../modulos/mapas/pantallas/barra_semana_pantalla.dart';
import '../modulos/principal/principal_pantalla.dart';
import '../modulos/principal/main_tab.dart';
import '../modulos/autenticacion/login/login_pantalla.dart';
import '../modulos/autenticacion/registro/registro_pantalla.dart';
import '../modulos/autenticacion/autenticacion_pantalla.dart';
import '../modulos/arranque/splash_pantalla.dart';
import '../modulos/mapas/controladores/barra_semana_controlador.dart';
import '../modulos/autenticacion/verificacion/verificacion_correo_pantalla.dart';
import '../modulos/usuario/usuarios_pantalla.dart';
import '../modulos/recordatorios/pantallas/editar_recordatorio_pantalla.dart';
import '../modulos/chatbot/chatbot_pantalla.dart';
import '../modulos/usuario/editar_perfil_pantalla.dart';
import '../modulos/foros/pantallas/crear_foro_pantalla.dart';
import '../modulos/foros/pantallas/foros_principal_pantalla.dart';
import '../modulos/foros/pantallas/mis_foros_pantalla.dart';
import '../modulos/foros/pantallas/chat_foro_pantalla.dart';
import '../modulos/foros/pantallas/info_foro_pantalla.dart';
import '../modulos/foros/pantallas/filtros_foro_pantalla.dart';
import '../admin/main_tab_admin.dart';
import '../modulos/foros/pantallas/accion_usuario_pantalla.dart';
import 'package:rutle_test/admin/usuarios/pantallas/usuarios_principal_pantalla.dart';
import '../recolector/main_tab_recolector.dart';

class RutasApp {
  static const usuarioAdmin = '/usuarioAdmin';
  static const accionUsuario = '/accionUsuario';
  static const accionPoder = '/accionPoder';
  static const filtrosForo = '/filtrosForo';
  static const infoForo = '/infoForo';
  static const chatForo = '/chatForo';
  static const misForos = '/misForos';
  static const detalleForo = '/detalleForo';
  static const editarPerfilPantalla = '/editarPerfil';
  static const chatBot = '/chatBot';
  static const editarRecordatorio = '/editRecordatorio';
  static const mainTab = '/mainTab';
  static const mainTabAdmin = '/mainTabAdmin';
  static const mainTabRecolector = '/mainTabRecolector';
  static const splash = '/';
  static const autenticacion = '/autenticacion';
  static const login = '/login';
  static const registro = '/registro';
  static const mapaPrincipal = '/mapaPrincipal';
  static const semanaPantalla = '/semanaPantalla';
  static const seleccionarDia = '/seleccionarDia';
  static const verificacionCorreo = '/verificacionCorreo';
  static const usuario = '/usuario';
  static const agregarRecordatorio = '/agregarRecordatorio';
  static const crearForo = '/crearForo';
  static const forosPrincipal = '/forosPrincipal';
  static const nuevosForos = '/nuevosForos';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {

    switch (settings.name) {

      case editarRecordatorio:

        final args = settings.arguments;

        if (args is! String) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(
                child: Text('Error: argumento inválido'),
              ),
            ),
          );
        }

        return MaterialPageRoute(
          builder: (_) => EditarRecordatorioPantalla(
            idRecordatorioDoc: args,
          ),
        );

      case editarPerfilPantalla:
        return MaterialPageRoute(
          builder: (_) => const EditarPerfilPantalla(),
        );

      case agregarRecordatorio:
        return MaterialPageRoute(
          builder: (_) => const AgregarRecordatorioPantalla(),
        );

      case chatBot:
        return MaterialPageRoute(
            builder: (_) => const ChatbotPantalla(),
        );

      case crearForo:
        return MaterialPageRoute(
          builder: (_) => const CrearForoPantalla(),
        );

        case forosPrincipal:
        return MaterialPageRoute(
          builder: (_) => const ForosPrincipalPantalla(),
        );

      case usuarioAdmin:
        return MaterialPageRoute(
          builder: (_) => const AdminPantalla(),
        );

      case usuario:
        return MaterialPageRoute(
          builder: (_) => const UsuarioPantalla(),
        );

      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashPantalla(),
        );

      case accionUsuario:
        final args = settings.arguments;

        if (args is! Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(
                child: Text('Error: argumento inválido'),
              ),
            ),
          );
        }

        return MaterialPageRoute(
          builder: (_) => AccionUsuarioPantalla(
            nombre: args['nombre'] ?? '',
            uid: args['uid'] ?? '',
            titulo: args['titulo'] ?? '',
            descripcion: args['descripcion'] ?? '',
          ),
        );

      case infoForo:
        final args = settings.arguments;

        if (args is! Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(
                child: Text('Error: argumento inválido'),
              ),
            ),
          );
        }

        return MaterialPageRoute(
          builder: (_) => InfoForoPantalla(foro: args),
        );

      case filtrosForo:
        return MaterialPageRoute(
          builder: (_) => const FiltrosForoPantalla(),
        );

      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginPantalla(),
        );

      case chatForo:
        final args = settings.arguments;

        if (args is! Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(
                child: Text('Error: argumento inválido'),
              ),
            ),
          );
        }

        return MaterialPageRoute(
          builder: (_) => ChatForoPantalla(
            titulo: args['titulo'] ?? '',
            descripcion: args['descripcion'] ?? '',
          ),
        );

      case registro:
        return MaterialPageRoute(
          builder: (_) => const RegistroPantalla(),
        );

      case misForos:
        return MaterialPageRoute(
          builder: (_) => const MisForosPantalla(),
        );

      case detalleForo:
        final args = settings.arguments;

        if (args is! Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(
                child: Text('Error: argumento inválido'),
              ),
            ),
          );
        }

  return MaterialPageRoute(
    builder: (_) => DetalleForoPantalla(foro: args),
  );

      case autenticacion:
        return MaterialPageRoute(
          builder: (_) => const AutenticacionPantalla(),
        );

      case nuevosForos:
        return MaterialPageRoute(
          builder: (_) => const NuevosForosPantalla(),
        );  

      case mainTab:
        return MaterialPageRoute(
          builder: (_) => const MainTab(),
        );

      case mainTabAdmin:
        return MaterialPageRoute(
          builder: (_) => const MainTabAdmin(),
        );

      case mainTabRecolector:
        return MaterialPageRoute(
          builder: (_) => const MainTabRecolector(),
        );

      case mapaPrincipal:
        return MaterialPageRoute(
          builder: (_) => const PrincipalPantalla(),
        );

      case semanaPantalla:
        return MaterialPageRoute(
          builder: (_) => const BarraSemanaPantalla(),
        );

      case seleccionarDia:
        final args = settings.arguments;

        if (args is! DestinoSemana) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(
                child: Text('Error: argumento inválido'),
              ),
            ),
          );
        }

        return MaterialPageRoute(
          builder: (_) => SeleccionarDiaPantalla(dia: args),
        );

      case verificacionCorreo:
        return MaterialPageRoute(
          builder: (_) => const VerificacionCorreoPantalla(),
        );
    }

    return null;
  }
}