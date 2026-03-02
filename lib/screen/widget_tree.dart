import 'package:flutter/material.dart';
import 'package:fire_app/auth.dart';
import 'package:fire_app/screen/home_page_screen.dart';
import 'package:fire_app/screen/login_register_screen.dart';


class WidgetTree extends StatefulWidget { 
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges,
      builder: (context,snapshot){
        if(snapshot.hasData){
          return HomePageScreen();
        }else{
          return const LoginPage();
        }
      }
    );
  }
}