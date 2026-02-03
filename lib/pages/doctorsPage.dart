import 'package:flutter/material.dart';


import 'package:medlandia/models/memberModel.dart';
import 'package:medlandia/screens/DoctorPage.dart';

class DoctorsPage extends StatefulWidget {
   const DoctorsPage({super.key});

  @override
  State<DoctorsPage> createState() => _DoctorsPageState();
}

class _DoctorsPageState extends State<DoctorsPage> {
final ScrollController _scrollController = ScrollController();

@override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // Detect when scrolled to the bottom
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      loadDoctors(index: doctorLoadIndex);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Loading...'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }
  
@override
  Widget build(BuildContext context) {
return Stack(
  fit: StackFit.expand,
  children: [ 
    
    ValueListenableBuilder(
    valueListenable: doctorsChanged,
    builder: (context, value, child) => 
      ListView.builder(
        controller: _scrollController,
        itemCount: doctors.length, 
      itemBuilder: (context, i) => 
        InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DoctorPage(doctorModel: doctors[i]))),
          child: Container(
            
            margin: EdgeInsets.symmetric(horizontal: 8, vertical:3),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: const Color.fromARGB(255, 235, 235, 236),
              border: Border.all(
                                color: const Color.fromARGB(207, 211, 211, 213), // Border color
                                width: 1.0, // Border thickness
                              )
            ),
            child: Column(
              children: [
                ListTile(                  
                  leading: ValueListenableBuilder(
                    valueListenable: doctors[i].userImageChangedNotifier,
                    builder: (context,_,__) =>
                            Stack(
                              children: <Widget>[
                                CircleAvatar(
                                  foregroundColor: Colors.amber,
                                  backgroundColor: Colors.blue,
                                  backgroundImage: doctors[i].userImage,
                                  radius: 25,
                                ),
                                Visibility(
                                  visible: false,
                                  child: Positioned(
                                        bottom: 0.0,
                                        right: 2.0,
                                        /*child: Container(
                                          height: 25,
                                          width: 25,
                                          decoration: BoxDecoration(
                                            color: const Color.fromARGB(255, 162, 169, 162),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text("😍", style: TextStyle(fontSize: 18),),
                                          ), //Icon(Icons.add, color: Colors.white, size: 15),                          
                                        ),*/
                                        child: Text("❤️", style: TextStyle(fontSize: 12),),
                                      ) 
                                  )
                                 
                                                  
                              ],
                            ),
                  ),
                          title: Text(doctors[i].name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                          subtitle: Text(DoctorModel.spetialityToString(doctors[i].speciality)),
                ),
                if (doctors[i].workplaceses.isNotEmpty)
                Align(
                  alignment: Alignment.topLeft,
                  child: Text("Works", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                ),
                
                for (int a = 0; a < doctors[i].workplaceses.length; a++) 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        SizedBox(width: MediaQuery.of(context).size.width/2.8, child: Text(doctors[i].workplaceses[a].hospitalName, softWrap: true, overflow: TextOverflow.clip, maxLines: 2)),                       
                        SizedBox(width: MediaQuery.of(context).size.width/2.2, child: Text(doctors[i].workplaceses[a].address, softWrap: true, overflow: TextOverflow.clip,)),
                        
                    ],
                  ),
   
  
                SizedBox(height: 15,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Expierence"),
                    Text("${doctors[i].getExpierenceYears()} years"),
                  ],
                ),              
                SizedBox(height: 3,),
                Divider(height: 2,),
                SizedBox(height: 5,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(doctors[i].binds > 10 ?    Icons.star_outlined : Icons.star_border, color: doctors[i].binds > 10 ? const Color.fromARGB(255, 131, 203, 236) : const Color.fromARGB(255, 189, 189, 189),),
                        Icon(doctors[i].binds > 50 ?    Icons.star_outlined : Icons.star_border, color: doctors[i].binds > 50 ? const Color.fromARGB(255, 131, 203, 236) : const Color.fromARGB(255, 189, 189, 189)),
                        Icon(doctors[i].binds > 100 ?   Icons.star_outlined : Icons.star_border, color: doctors[i].binds > 100 ? const Color.fromARGB(255, 131, 203, 236) : const Color.fromARGB(255, 189, 189, 189)),
                        Icon(doctors[i].binds > 200 ?   Icons.star_outlined : Icons.star_border, color: doctors[i].binds > 200 ? const Color.fromARGB(255, 131, 203, 236) : const Color.fromARGB(255, 189, 189, 189)),
                        Icon(doctors[i].binds > 300 ?   Icons.star_outlined : Icons.star_border, color: doctors[i].binds > 300 ? const Color.fromARGB(255, 131, 203, 236) : const Color.fromARGB(255, 189, 189, 189) )
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.link_rounded),
                        Text(doctors[i].getBindsText())
                      ],
                    )
                   
                  ],
                )
              ],
            ),
          ),
        )
      )
  )],
);

  }
}