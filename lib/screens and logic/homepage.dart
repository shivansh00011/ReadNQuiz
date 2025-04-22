import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readnquiz/screens%20and%20logic/FAQgeneration.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String name = "";
    void initState() {
    super.initState();
    fetchUserData(); 
  }
    Future<void> fetchUserData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          name = data['name'] ?? '';
        
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
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
          )
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 70),
                child: Text("Welcome,", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.white),),
              ),
              const SizedBox(height: 2,),
              Text(name, style: GoogleFonts.poppins(fontSize: 16, color: const Color.fromARGB(255, 221, 220, 220), fontWeight: FontWeight.w300),),
              const SizedBox(height: 40,),
              Text("Upload.Play.Ask", style: GoogleFonts.sora(fontSize: 57, color: Colors.white, fontWeight: FontWeight.w500),),
              const SizedBox(height: 30,),
              Text("Your Uploads", style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),),
              const SizedBox(height: 30,),
               DottedBorder(
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(12),
                        color: Colors.grey,
                        strokeWidth: 1.5,
                        dashPattern: const [8, 4],
                        child: InkWell(
                          onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context)=> PDFUploadScreen()));
                          },
                          child: Container(
                            width: double.infinity,
                            height: 95,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add, size: 30, color: Colors.black54),
                                const SizedBox(height: 8),
                                Text(
                                  "Upload document and get started",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      );
    
  }
}
              
          
 