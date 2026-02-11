import 'package:flutter/material.dart';

class InfoHome extends StatefulWidget {
  const InfoHome({super.key, this.title, this.subtitle, this.icon, 
  required this.actions, required this.content, this.topTapAction});
  final String? title;
  final String? subtitle;
  final String? icon;
  final List<Widget> actions;
  final Function content;
  final Function? topTapAction;


  

  @override
  State<InfoHome> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 240, 244),
      /*appBar: PreferredSize(
        preferredSize: Size.fromHeight(60), 
        child: AppBar(
          backgroundColor: const Color.fromARGB(255, 230, 230, 232),
          leadingWidth: 80,
          titleSpacing: 0,
          
          leading: InkWell(
            onTap: () { if(widget.topTapAction != null) { widget.topTapAction!();} },
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //Icon(Icons.arrow_back, size: 24),
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: widget.icon != null ? NetworkImage(widget.icon!) : AssetImage("assets/images/logo-512.jpg"),
                  )
                ],
              ),
          ),
          title: Container(
            margin: EdgeInsets.all(6.0),
            child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title != null ? widget.title! : "",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        widget.subtitle != null ? widget.subtitle! : "",
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
          ),
          actions: widget.actions,
        )
        ),*/
        
    );
  }
}