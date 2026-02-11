
import 'package:flutter/material.dart';
import 'package:medlandia/models/DoctorSkillsModel.dart';
import 'package:medlandia/models/countryModel.dart';
import 'package:medlandia/models/memberModel.dart';
import 'package:medlandia/models/spetialityModel.dart';
import 'package:medlandia/models/workplaceModel.dart';

void showCenterMenuDialog(BuildContext context, Widget items) {
    showDialog(context: context, 
                builder: (BuildContext context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0)),
                    child: Container(
                      padding: EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Choose an Option',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),
                          items
                        ],
                      ),
                    ),  
                  );
                });
  }

Widget buildMenuOption(BuildContext context,String text,IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: () {         
        Navigator.pop(context);   
        onTap();                    
        },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            SizedBox(width: 15),
            Text(text, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }


  List<DropdownMenuItem<Workplace>> getWorkplacesDropDownList() {
    List<DropdownMenuItem<Workplace>> list = [];
    for (Workplace w in (currentUser as DoctorModel).workplaceses) {
      list.add(DropdownMenuItem(value: w, child: Text('${w.hospitalName}:${w.address}', style: TextStyle(fontSize: 16))),);
    }
    return list;
  }

   List<DropdownMenuItem<SpetialityModel>> getSpetialityDropDownList() {
    List<DropdownMenuItem<SpetialityModel>> list = [];
    for (SpetialityModel sp in dummyAllSpetialities) {
      list.add(DropdownMenuItem(value: sp, child: Text(sp.name, style: TextStyle(fontSize: 16))),);
    }
    return list;
  }

    List<DropdownMenuItem<CountryModel>> getCountryDropDownList() {
    List<DropdownMenuItem<CountryModel>> list = [];
    for (CountryModel sp in dummyCountries) {
      list.add(DropdownMenuItem(value: sp, child: Text(sp.country, style: TextStyle(fontSize: 16))),);
    }
    return list;
  }

  List<DropdownMenuItem<DoctorSkillsModel>> getSkillsDropDownList() {
    List<DropdownMenuItem<DoctorSkillsModel>> list = [];

    for (DoctorSkillsModel sk in (currentUser as DoctorModel).skills) {
      list.add(DropdownMenuItem<DoctorSkillsModel>(
        value: sk, 
        child: Text('${sk.skillName}:${sk.skillDescr}' , style: TextStyle(fontSize: 16)
      )
      )); 
    }

    return list;
  }
