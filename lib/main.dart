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
import 'features/profile/services/profile_service.dart';

// 전역 navigatorKey 추가
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
        ChangeNotifierProvider(
          create: (_) => ProfileService(),
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
            navigatorKey: navigatorKey, // navigatorKey 추가
            title: 'Yolog',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              fontFamily: 'Pretendard',
              brightness: themeProvider.theme.brightness,
              colorScheme: themeProvider.theme.colorScheme,
              appBarTheme: AppBarTheme(
                backgroundColor:
                    themeProvider.theme.brightness == Brightness.dark
                        ? Colors.grey[900]
                        : Colors.white,
                foregroundColor:
                    themeProvider.theme.brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                elevation: 0,
              ),
              scaffoldBackgroundColor:
                  themeProvider.theme.brightness == Brightness.dark
                      ? Colors.black
                      : Colors.white,
              textTheme: ThemeData.light().textTheme.apply(
                    fontFamily: 'Pretendard',
                    bodyColor: themeProvider.theme.brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                    displayColor:
                        themeProvider.theme.brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                  ),
              primaryTextTheme: ThemeData.light().textTheme.apply(
                    fontFamily: 'Pretendard',
                    bodyColor: themeProvider.theme.brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                    displayColor:
                        themeProvider.theme.brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                  ),
            ),
            routes: AppRoutes.getRoutes(),
            initialRoute: AppRoutes.initial,
            onGenerateRoute: AppRoutes.onGenerateRoute,
            onUnknownRoute: AppRoutes.onUnknownRoute,
          );
        },
      ),
    );
  }
}
