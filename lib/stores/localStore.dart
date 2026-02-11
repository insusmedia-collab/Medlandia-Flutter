

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:medlandia/models/DoctorSkillsModel.dart';
import 'package:medlandia/models/memberModel.dart';
import 'package:medlandia/models/spetialityModel.dart';
import 'package:medlandia/models/workplaceModel.dart';

class LocalStore {

static IOSOptions _getIOSOptions() => IOSOptions(accountName: null);

  static AndroidOptions _getAndroidOptions() => const AndroidOptions(
    encryptedSharedPreferences: true,
    // sharedPreferencesName: 'Test2',
    // preferencesKeyPrefix: 'Test'
  );

  static Future<void> update({
    required String key,
    required String value,
  }) async {
    final store = FlutterSecureStorage(
      iOptions: _getIOSOptions(),
      aOptions: _getAndroidOptions(),
    );
    store.write(key: key, value: value);
  }

static Future<String?> read(String key) async {
    final store = FlutterSecureStorage(
      iOptions: _getIOSOptions(),
      aOptions: _getAndroidOptions(),
    );
    String? k = await store.read(key: key);
    return k;
  }

  static Future<void> delete(String key) async {
    final store = FlutterSecureStorage(
      iOptions: _getIOSOptions(),
      aOptions: _getAndroidOptions(),
    );
    await store.delete(key: key);
  }

  static Future<void> deleteAll() async {
    final store = FlutterSecureStorage(
      iOptions: _getIOSOptions(),
      aOptions: _getAndroidOptions(),
    );
    await store.deleteAll();
  }

  static Future<void> write({required String key, required String value}) async {
    final store = FlutterSecureStorage(
      iOptions: _getIOSOptions(),
      aOptions: _getAndroidOptions(),
    );
    await store.write(key: key, value: value);
  }

static Future<Map<String, String>> readAll() async {
    final store = FlutterSecureStorage(
      iOptions: _getIOSOptions(),
      aOptions: _getAndroidOptions(),
    );
    Map<String, String> all = await store.readAll();
    return all;
  }

 static void buildCurrentUser(
    Map<String, dynamic> user,
    List<dynamic> sp,
    List<dynamic> wp,
    List<dynamic> skills
  ) {
    
    /*************************** INITIALIZE CURRENT USER******************************* */

    if (user['userType'] == 0) {
      
      currentUser = MemberModel(
        id: user['id'],
        name: user['name'],
        chatName: user['name'],
        userImage: NetworkImage(user['avatar']),
        country: user['country'],
        language: user['language']
      );
      currentUser?.email = user['email'];
    } else if (user['userType'] == 1) {
      currentUser = DoctorModel(
        id: user['id'],
        name: user['name'],
        chatName: user['name'],
        speciality: [],
        workplaceses: [],
        userImage: NetworkImage(user['avatar']),
        country: user['country'],
        language: user['language']
      );
      currentUser?.email = user['email'];
    } else {
      throw ArgumentError("Anknown user type ${user['userType']}");
    }

    /******************* initialize spetialities and workplaces******************************* */

    for (var item in sp) {
      (currentUser as DoctorModel).speciality.add(
        SpetialityModel(id: item['id'], name: item['spec']),
      );

    }

    for (var item in skills) {      
      (currentUser as DoctorModel).skills.add(DoctorSkillsModel(user2skillId: item['id'], skillId: item['skillsId'], userId: item['userId'], skillName: item['value'], skillDescr: item['descr']));
    }

    for (var item in wp) {
      (currentUser as DoctorModel).workplaceses.add(
        Workplace(
          address: item['address'],
          googlePlaceId: item['googlePlaceId'],
          hospitalName: item['work'],
          hospitalId: item['workplaceId'],
          placeId: item['placeId'],
          lon: item['lon'],
          lat: item['lat'],
          id: item['id'],
        ),
      );
      
    }
    
  }

}


