import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'core/providers/theme_provider.dart';
import 'core/routes/app_routes.dart';
import 'features/post/services/post_service.dart';
import 'features/post/repositories/post_repository.dart';
import 'firebase_options.dart';
import 'features/auth/providers/auth_provider.dart' as app_auth;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final prefs = await SharedPreferences.getInstance();

  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({Key? key, required this.prefs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(prefs),
        ),
        ChangeNotifierProvider(
          create: (_) => app_auth.AuthProvider(),
        ),
        Provider<PostRepository>(
          create: (_) => PostRepository(),
        ),
        ChangeNotifierProvider(
          create: (context) => PostService(
            auth: FirebaseAuth.instance,
            postRepository: context.read<PostRepository>(),
          ),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Yolog',
            theme: themeProvider.theme,
            routes: AppRoutes.getRoutes(),
            initialRoute: AppRoutes.home,
            onGenerateRoute: AppRoutes.onGenerateRoute,
            onUnknownRoute: AppRoutes.onUnknownRoute,
          );
        },
      ),
    );
  }
}
