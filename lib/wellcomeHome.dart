import 'package:flutter/material.dart';
import 'package:medlandia/screens/language.dart';

class Wellcome extends StatelessWidget {
  const Wellcome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 240, 244),
      body:  SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.symmetric(horizontal: 45, vertical: 25),
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height / 6.5),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: Image.asset("assets/images/logo-512.jpg").image,
                  ),
                  SizedBox(height: 18,),
                  Text("Medlandia", style: TextStyle(fontFamily: "Arial", color: const Color.fromARGB(255, 2, 48, 127), fontSize: 32, fontWeight: FontWeight.bold),),
                  SizedBox(height: 10,),

                  Center(child: Text(textAlign: TextAlign.center, "Medlandia is a doctor and patient fast and productive communication tool.", 
                  style: TextStyle(fontSize: 16),)),
                  
                  SizedBox(height: 25,),
                  
                  TextButton(
                    onPressed: (){}, 
                    child: Text("Read Terms of condition and aggrement.If you start thats meen that you are agree with terms of condition", 
                            textAlign: TextAlign.center,
                            style: TextStyle(color:const Color.fromARGB(255, 65, 65, 71), fontSize:  12),),
                      ),
                   
                  Expanded(child: Text("")),
                  
                  SizedBox(height: 50,),
                  TextButton(
                    onPressed: () {

                       Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LanguageScreen()));
                    }, 
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          style: BorderStyle.solid,
                          width: 2,
                          color: const Color.fromARGB(255, 36, 71, 209),
                        )
                      ),
                      padding: EdgeInsets.all(7),
                      child: Text("Let's go", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                      )
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height / 10.8,),
                  Text("Medlandia\u00A9 2025. All rights saved.", textAlign: TextAlign.center,)
                ],
              ),
            ),
        ),
    );
  }
}