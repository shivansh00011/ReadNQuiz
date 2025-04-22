import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readnquiz/screens%20and%20logic/login.dart';

class Resetpassword extends StatefulWidget {
  const Resetpassword({super.key});

  @override
  State<Resetpassword> createState() => _ResetpasswordState();
}

class _ResetpasswordState extends State<Resetpassword> {
  TextEditingController _emailController = new TextEditingController();
    Future<void> resetPassword() async {
    try {
      // Attempt to send the reset email
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password Reset Email Has Been Sent"),
        ),
      );
    } on FirebaseAuthException catch (e) {
      // Check for specific error codes
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Email not registered. Please check the email address."),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("An error occurred. Please try again."),
          ),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Container(
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
          )),
          child:Padding(
            padding: const EdgeInsets.only(left: 20,right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 180),
                  child: Text("Reset Password", style: GoogleFonts.poppins(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),),
                ),
                const SizedBox(height: 5,),
                Text("Enter your email to get the reset password link",style: GoogleFonts.dmSerifText(fontSize: 17, color: const Color.fromARGB(255, 221, 221, 221)),),
                const SizedBox(height: 60),
                Text(
                  "Email",
                  style: GoogleFonts.montserrat(
                      fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 12,),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'example@gmail.com',
                    hintStyle: GoogleFonts.montserrat(fontSize: 13, color: const Color.fromARGB(255, 226, 225, 225), fontWeight: FontWeight.bold),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.0), // transparent
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.white60),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.white70),
                    ),
                  ),
                  style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold
                  ),
                ),
                 const SizedBox(height: 30,),
              Container(
                height: 70,
                width: double.maxFinite,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 239, 218, 103),
                  borderRadius: BorderRadius.circular(34),

                ),
                child: GestureDetector(
                  onTap: resetPassword,
                  child: Center(child: Text("Send the reset link", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold),),)),
              ),
              const SizedBox(height: 15,),
              GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> Login()));
                },
                child: Center(
                  child: Text('Back to login', style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),),
                ),
              )
                ] ,
            ),
          ) ),
    );
  }
}