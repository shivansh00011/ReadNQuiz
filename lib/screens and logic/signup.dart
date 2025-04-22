import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readnquiz/screens%20and%20logic/login.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  bool obscurePassword = true;
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
      final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    Future<void> _signUp() async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'name': _nameController.text,
        'email': _emailController.text,
        'uid': userCredential.user?.uid,
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    } on FirebaseAuthException catch (e) {
      print(e.message);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? "Signup failed"),
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
          )),
          child: Padding(
          padding: const EdgeInsets.only(left: 20,right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 180),
                child: Text("SignUp", style: GoogleFonts.poppins(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),),
              ),
              const SizedBox(height: 5,),
              Text("Enter your name, email and password to signup",style: GoogleFonts.dmSerifText(fontSize: 17, color: const Color.fromARGB(255, 221, 221, 221)),),
              const SizedBox(height: 60),
              Text(
                "Name",
                style: GoogleFonts.montserrat(
                    fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 12,),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'David',
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

              const SizedBox(height: 20),

              Text(
                "Email",
                style: GoogleFonts.montserrat(
                    fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            
              const SizedBox(height: 12),
              
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
              const SizedBox(height: 20),
              Text(
                "Password",
                style: GoogleFonts.montserrat(
                    fontSize: 15,  color:  Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  hintText: '***********',
                  hintStyle: GoogleFonts.montserrat(fontSize: 13,color: const Color.fromARGB(255, 226, 225, 225), fontWeight: FontWeight.bold),
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
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility_off : Icons.visibility,color: Colors.white,
                     
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
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
                  onTap: _signUp,
                  child: Center(child: Text("SignUp", style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold),),)),
              ),
              const SizedBox(height: 16,),
              GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> Login()));
                },
                child: Center(child: Text("Already have an account?", style: GoogleFonts.poppins(color: Colors.white, fontSize: 15),),))
          
            ],
          ),
        ),
      ),
    );
  }
}