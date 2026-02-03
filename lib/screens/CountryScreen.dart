import 'package:flutter/material.dart';
import 'package:medlandia/models/countryModel.dart';

class CountryScreen extends StatelessWidget {
  final Function setCountry;
  const CountryScreen({super.key, required this.setCountry});
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 240, 244),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor:  Color.fromARGB(255, 230, 230, 232),
        elevation: 0.0,
        leading: InkWell(child: Icon(Icons.arrow_back), onTap: () => Navigator.pop(context),),
        title: Text("Country", style: TextStyle(fontWeight: FontWeight.w700, wordSpacing: 1.0)),
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: dummyCountries.length,
          itemBuilder: (context, i) => countryRow(dummyCountries[i])),
      ),
    );
  }
  Widget countryRow(CountryModel country) {
    return InkWell(
      onTap: () => setCountry(country),
      child: Card(
        margin: EdgeInsets.all(0.15),
        child: Container(
          height: 60.0,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: Row(
            children: [
              ClipOval(
                child: Text(country.flagUrl, style: TextStyle(fontSize: 32),) //Image.network(country.flagUrl, width: 40, height: 40, fit: BoxFit.cover,),
              ),
            SizedBox(width: 10),
            Expanded(child: Text(country.country, style: TextStyle(fontSize: 18),)),
            Text(country.code.toString())
            ],
          ),
        ),
      ),
    );
  }
}