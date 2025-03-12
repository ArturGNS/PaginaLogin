import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:myapp/pages/login_page.dart';


void main (){
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red, // define a palta de cores primaria
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.red, //define a cor de fundo da AppBar
        ),
      ),
      home: const LoginPage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var numeroGerado = 0;

  int _gerarNumeroAleatorio(){
    math.Random numeroAleatorio = math.Random();
    return numeroAleatorio.nextInt(1000);
  }


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Meu APP")),
      ),
        body: Center(child: Text(numeroGerado.toString())),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add_a_photo),
          onPressed: () {
            setState(() {
              numeroGerado = _gerarNumeroAleatorio();
            });
            print(numeroGerado); //exibe o numero gerado no console
          },
        ),
      );

  }
}