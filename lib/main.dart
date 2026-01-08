import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loan_app/providers/theme_provider.dart';
import 'package:loan_app/screen.dart';
import 'package:loan_app/screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:loan_app/providers/currency_provider.dart';
import 'package:loan_app/theme/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://snyndblegwhgzhtfopim.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNueW5kYmxlZ3doZ3podGZvcGltIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc4NTIyMTAsImV4cCI6MjA4MzQyODIxMH0.TNVTwQQlJqXwSTN8pp3jGCFJaGvhbldrTbhDgme1U6I',
  );
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyRootApp());
}

class MyRootApp extends StatelessWidget {
  const MyRootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CurrencyProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Loan App',
            theme: ThemeData(
              brightness: Brightness.light,
              fontFamily: 'Lato',
              scaffoldBackgroundColor: AppColors.scaffold,
              primaryColor: AppColors.primary,
              cardColor: AppColors.white,
              dividerColor: AppColors.borderGrey,
              colorScheme: ColorScheme.light(
                primary: AppColors.primary,
                secondary: AppColors.primaryDark,
                background: AppColors.scaffold,
                error: AppColors.error,
              ),
              textTheme: const TextTheme(
                bodyMedium: TextStyle(color: AppColors.textPrimary),
              ),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              fontFamily: 'Lato',
              scaffoldBackgroundColor: AppDarkColors.scaffold,
              primaryColor: AppDarkColors.primary,
              cardColor: AppDarkColors.card,
              dividerColor: AppDarkColors.border,
              colorScheme: ColorScheme.dark(
                primary: AppDarkColors.primary,
                secondary: AppDarkColors.tabActive,
                background: AppDarkColors.scaffold,
                error: AppDarkColors.error,
              ),
              textTheme: const TextTheme(
                bodyMedium: TextStyle(color: AppDarkColors.textPrimary),
              ),
            ),

            themeMode: themeProvider.materialThemeMode,
            home: SplashScreen(),
          );
        },
      ),
    );
  }
}
