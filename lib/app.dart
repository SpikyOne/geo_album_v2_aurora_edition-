import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import 'providers/navigation_provider.dart';
import 'screens/home_screen.dart';



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(

      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],

    child: MaterialApp(

      title: 'Photo Gallery',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),

      home: const HomeScreen(),
    ),

    );
  }
}
