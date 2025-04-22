import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readnquiz/screens%20and%20logic/nav.dart';
import 'package:readnquiz/screens%20and%20logic/resetpassword.dart';
import 'package:readnquiz/screens%20and%20logic/signup.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool obscurePassword = true;
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  bool isLoading = false;
    Future<void> loginUser() async {
    setState(() {
      isLoading = true; // Start loading spinner
    });

    try {
      // Firebase authentication for signing in with email and password
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Navigate to HomePage on successful login
     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const Nav()));

    } catch (e) {
      // Display an error message if sign in fails
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid credentials. Please try again."),
        ),
      );
    } finally {
      setState(() {
        isLoading = false; // Stop loading spinner
      });
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
          )
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 20,right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 180),
                child: Text("Login", style: GoogleFonts.poppins(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),),
              ),
              const SizedBox(height: 5,),
              Text("Enter your email and password to login",style: GoogleFonts.dmSerifText(fontSize: 17, color: const Color.fromARGB(255, 221, 221, 221)),),
              const SizedBox(height: 60),
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
              const SizedBox(height: 12,),
              GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>Resetpassword()));
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 275),
                  child: Text("Forgot Password?", style: GoogleFonts.dmSerifText(fontSize: 15,color: const Color.fromARGB(255, 233, 232, 232)),),
                ),
              ),
              const SizedBox(height: 30,),
              GestureDetector(
                onTap: loginUser,
                child: Container(
                  height: 70,
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 239, 218, 103),
                    borderRadius: BorderRadius.circular(34),
                
                  ),
                  child: Center(child: Text("Login", style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold),),),
                ),
              ),
              const SizedBox(height: 16,),
              GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> Signup()));
                },
                child: Center(child: Text("Don't have an account?", style: GoogleFonts.poppins(color: Colors.white, fontSize: 15),),))
          
            ],
          ),
        ),
      ),
    );
  }
}