import 'dart:convert';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../Services/network/NetworkUtils.dart';
import '../model/DriverRidesResponse.dart';
import '../model/NewDriverScheduledRide2.dart';
import '../model/Respons/data.dart';
 
class NewDriverNormalRidesController extends GetxController {
  // List to store rides
    var isScheduledRides = false; // This will manage the switch state.
NewDriverScheduledRide? selectitem ;
 DriverRidesResponse ?driverRidesResponse   ;
  List<NewDriverScheduledRide> ridesNewDriverScheduledRides = [];
     Map data = {};
  
  // Loading state
bool isLoading = false;


updatePrice(NewDriverScheduledRide? value){

  selectitem = value;
  update();
}

updatePriceClose( ){

  selectitem = null;
  update();
}
  // Fetch data from the API
 Future<void> fetchRides() async {
  isLoading = true;
update();
  try {
    // Make the HTTP request
    var response = await buildHttpResponse('getNewDriverRides', method: HttpMethod.GET);

    if (response.statusCode == 200) {
      // Parse the response body
      final responseBody = jsonDecode(response.body);

      // Check the status in the response
      if (responseBody['status'] == true) {
        // Parse the response into the DriverRidesResponse model
        driverRidesResponse = DriverRidesResponse.fromJson(responseBody);
update();
        // Log success and fetched data
        Logger().i('Fetched rides successfully: ${driverRidesResponse!.message}');
        Logger().i('Normal Rides Count: ${driverRidesResponse!.newDriverNormalRides.length}');
        Logger().i('Scheduled Rides Count: ${driverRidesResponse!.newDriverScheduledRides.length}');
      } else {
        // Handle an unsuccessful response
        Logger().w('Failed to fetch rides: ${responseBody['message']}');
        driverRidesResponse = null;
        update();
        // Get.snackbar('Error', responseBody['message'] ?? 'Unknown error occurred');
      }
    } else {
     driverRidesResponse = null;
        update();
      Logger().e('HTTP Error: ${response.statusCode} - ${response.reasonPhrase}');
      // Get.snackbar('Error', 'Failed to fetch rides: HTTP ${response.statusCode}');
    }
  } catch (e) {
     driverRidesResponse = null;
        update();
    Logger().e('Exception: $e');
    // Get.snackbar('Error', 'Failed to fetch rides: $e');
  } finally {
    // Always update the loading state and UI
    isLoading = false;
    update();
  }
}


  // Refresh the rides
  Future<void> refreshRides() async {
 
   fetchRides();
 
  }
 
  @override
  void onInit() {
    super.onInit();
    refreshRides();
  }
  // // Get ride by ID
  // NewDriverNormalRides? getRideByxId(int id) {
  //   return ridesNewDriverNormalRides.firstWhereOrNull((ride) => ride.id == id);
  // } 
  
   NewDriverScheduledRide? getNewDriverScheduledRidesRideById(int id) {
    return ridesNewDriverScheduledRides.firstWhereOrNull((ride) => ride.id == id);
  }
}
