
class Workplace{
  late int id;
  final int hospitalId;
  final String hospitalName;
  final int placeId;
  final String address;
  late  double? lon;
  late double? lat;
  String googlePlaceId;

  Workplace({required this.id,
              required this.placeId,
              required this.hospitalId,
              required this.hospitalName, 
              required this.address, 
              required this.lat, 
              required this.lon, 
              required this.googlePlaceId });

  Map<String, dynamic> toJson() {
    return {
      'id' : id,
      'hospitalId'    : hospitalId,
      'hospitalName'  : hospitalName,
      'placeId'       : placeId,
      'address'       : address,
      'lon'           : lon,
      'lat'           : lat,
      'googlePlaceId' : googlePlaceId

    };
  }

}

