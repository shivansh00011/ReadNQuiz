import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readnquiz/screens%20and%20logic/login.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
      Future<void> logOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> Login())); // Replace with your login page route
    } catch (e) {
      print('Error logging out: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error logging out. Please try again.',
            style: GoogleFonts.montserrat(),
          ),
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [
            Color.fromARGB(255, 30, 60, 114),
            Color.fromARGB(255, 42, 82, 152),
            Color.fromARGB(255, 109, 213, 250)


          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight
          ),
          
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 70,left: 20,right: 20),
          child: GestureDetector(
            onTap: ()=>logOut(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 60,
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 239, 218, 103),
                          borderRadius: BorderRadius.circular(34),
                  ),
                  child: Center(child: Text("Logout", style: GoogleFonts.poppins(fontSize: 16, color: Colors.black),)),
                ),
              ],
            ),
          ),
        ) ,
        )
    );
  }
}