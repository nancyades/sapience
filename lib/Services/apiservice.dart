import 'dart:async';
import 'dart:convert';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constant/api_url.dart';
import '../helper/appconstant.dart';

final apiprovider = Provider<ApiProvider>((ref) => ApiProvider(ref));

class ApiProvider {
  final Ref? ref;

  ApiProvider(this.ref);

  Future<void> clearAllCacheWithPrefix(String prefix) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Set<String> keys = prefs.getKeys();
    for (String key in keys.where((key) => key.startsWith(prefix))) {
      await prefs.remove(key);
    }
  }
  Future<void> clearCacheForKey(String cacheKey) async {
    // Implement your cache clearing logic here for the specific cacheKey
    // For example, you might use the DefaultCacheManager to remove the file
    await DefaultCacheManager().removeFile(cacheKey);
  }
  Future<String> getOtp(String phoneNo) async {
    try {
      var url = Uri.parse(AppUrl.getotpUrl(phoneNo));
      var response = await http.post(url).timeout(Duration(seconds: 25));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        return data['message'] ?? "OTP sent successfully.";
      } else {
        return "Failed to send OTP. Status code: ${response.statusCode}";
      }
    } catch (e) {
      return "Something went wrong. Please try again!";
    }
  }

  Future<dynamic> getLogin(String phoneNo, String otp) async {
    try {
      var url = Uri.parse(AppUrl.getloginUrl(phoneNo, otp));
      var response = await http.post(url).timeout(Duration(seconds: 25));
      var data = json.decode(response.body);

      if (response.statusCode == 200 && data['success']) {
        UserPreferences.savePhoneno(data['data']['phone']);
        await UserPreferences.saveToken(data['data']['token']);
        return data;
      } else if (response.statusCode == 404) {
        return data;
      }
    } on TimeoutException {
      return {"success": false, "message": "Timeout"};
    } catch (e) {
      return "Something went wrong. Please try again!";
    }
  }

  Future<dynamic> getBookQrCode(String qrCode) async {

    return _getDataWithAuthHeader(AppUrl.getbookqrUrl(qrCode));
  }

  Future<dynamic> getSection() async {
    return _getCachedData(
      cacheKey: "API_Section",
      fetchFromApi: _fetchSectionDataFromApi,
    );
  }

  Future<dynamic> getTerms(String sectionId) async {
    return _getCachedData(
      cacheKey: 'API_getterms_$sectionId',
      fetchFromApi: (prefs, key) => _fetchDataFromApi(
        url: AppUrl.getterms(sectionId),
        prefs: prefs,
        cacheKey: key,
      ),
    );
  }

  Future<dynamic> getMonth(String sectionId, String termId) async {
    return _getCachedData(
      cacheKey: 'API_getmonth_${sectionId}_$termId',
      fetchFromApi: (prefs, key) => _fetchDataFromApi(
        url: AppUrl.getmonth(sectionId, termId),
        prefs: prefs,
        cacheKey: key,
      ),
    );
  }

  Future<dynamic> getWeek(
      String sectionId, String termId, String monthId) async {
    return _getCachedData(
      cacheKey: 'API_getweek_${sectionId}_${termId}_${monthId}',
      fetchFromApi: (prefs, key) => _fetchDataFromApi(
        url: AppUrl.getweek(sectionId, termId, monthId),
        prefs: prefs,
        cacheKey: key,
      ),
    );
  }

  Future<dynamic> getSubject(
    String sectionId,
    String termId,
    String monthId,
    String weekId,
  ) async {
    return _getCachedData(
      cacheKey: 'API_getsubject_${sectionId}_${termId}_${monthId}_${weekId}',
      fetchFromApi: (prefs, key) => _fetchDataFromApi(
        url: AppUrl.getsubject(sectionId, termId, monthId, weekId),
        prefs: prefs,
        cacheKey: key,
      ),
    );
  }

  Future<dynamic> getVideoCategory(
    String sectionId,
    String termId,
    String monthId,
    String weekId,
    String subjectId,
  ) async {
    return _getCachedData(
      cacheKey:
          'API_getvideocategory_${sectionId}_${termId}_${monthId}_${weekId}_$subjectId',
      fetchFromApi: (prefs, key) => _fetchDataFromApi(
        url: AppUrl.getvideocategorey(
            sectionId, termId, monthId, weekId, subjectId),
        prefs: prefs,
        cacheKey: key,
      ),
    );
  }

  Future<dynamic> getVideo(
    String sectionId,
    String termId,
    String monthId,
    String weekId,
    String subjectId,
    String category,
  ) async {
    return _getCachedData(
      cacheKey:
          'API_getvideo_${sectionId}_${termId}_${monthId}_${weekId}_${subjectId}_$category',
      fetchFromApi: (prefs, key) => _fetchDataFromApi(
        url: AppUrl.getvideo(
            sectionId, termId, monthId, weekId, subjectId, category),
        prefs: prefs,
        cacheKey: key,
      ),
    );
  }

  Future<dynamic> foodCategory() async {
    return _getCachedData(
      cacheKey: "API_foodcategory",
      fetchFromApi: _fetchFoodCategoryDataFromApi,
    );
  }

  Future<dynamic> foodDays() async {
    return _getCachedData(
      cacheKey: "API_fooddays",
      fetchFromApi: _fetchFoodDaysDataFromApi,
    );
  }

  Future<dynamic> foodType() async {
    return _getCachedData(
      cacheKey: "API_foodtype",
      fetchFromApi: _fetchFoodTypeDataFromApi,
    );
  }

  Future<dynamic> foodVideo(
      String foodCategory, String foodType, String foodDay) async {
    return _getCachedData(
      cacheKey: 'API_foodvideo${foodCategory}_${foodType}_${foodDay}',
      fetchFromApi: (prefs, key) => _fetchDataFromApi(
        url: AppUrl.getfoodvideo(foodCategory, foodType, foodDay),
        prefs: prefs,
        cacheKey: key,
      ),
    );
  }

  Future<dynamic> setting() async {
    return _getCachedData(
      cacheKey: "API_setting",
      fetchFromApi: _fetchSettingDataFromApi,
    );
  }

  Future<dynamic> sliderVideo() async {
    return _getCachedData(
      cacheKey: "API_slidervideo",
      fetchFromApi: _fetchSliderVideoDataFromApi,
    );
  }

  Future<dynamic> _getCachedData({
    required String cacheKey,
    required Future<dynamic> Function(SharedPreferences, String) fetchFromApi,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var connectivityResult = await Connectivity().checkConnectivity();
    bool isOnline = connectivityResult != ConnectivityResult.none;

    var cacheData = prefs.getString(cacheKey);
    if (cacheData != null) {
      Map<String, dynamic> cacheContent = json.decode(cacheData);
      DateTime cacheCreationDate = DateTime.parse(cacheContent['timestamp']);
      var cacheAge = DateTime.now().difference(cacheCreationDate).inHours;

      if (cacheAge < 4) {
        return cacheContent['data'];
      } else {
        if (isOnline) {
          await prefs.remove(cacheKey);
          return fetchFromApi(prefs, cacheKey);
        } else {
          return cacheContent['data'];
        }
      }
    } else {
      if (isOnline) {
        return fetchFromApi(prefs, cacheKey);
      } else {
        return "Nocache";
      }
    }
  }

  Future<dynamic> _fetchSectionDataFromApi(
      SharedPreferences prefs, String cacheKey) async {
    return _fetchDataFromApi(
      url: AppUrl.getsection(),
      prefs: prefs,
      cacheKey: cacheKey,
    );
  }

  Future<dynamic> _fetchFoodCategoryDataFromApi(
      SharedPreferences prefs, String cacheKey) async {
    return _fetchDataFromApi(
      url: AppUrl.getfoodcategory(),
      prefs: prefs,
      cacheKey: cacheKey,
    );
  }

  Future<dynamic> _fetchFoodDaysDataFromApi(
      SharedPreferences prefs, String cacheKey) async {
    return _fetchDataFromApi(
      url: AppUrl.getfooddays(),
      prefs: prefs,
      cacheKey: cacheKey,
    );
  }

  Future<dynamic> _fetchFoodTypeDataFromApi(
      SharedPreferences prefs, String cacheKey) async {
    return _fetchDataFromApi(
      url: AppUrl.getfoodtype(),
      prefs: prefs,
      cacheKey: cacheKey,
    );
  }

  Future<dynamic> _fetchSettingDataFromApi(
      SharedPreferences prefs, String cacheKey) async {
    return _fetchDataFromApi(
      url: AppUrl.setting(),
      prefs: prefs,
      cacheKey: cacheKey,
    );
  }

  Future<dynamic> _fetchSliderVideoDataFromApi(
      SharedPreferences prefs, String cacheKey) async {
    return _fetchDataFromApi(
      url: AppUrl.sildervideo(),
      prefs: prefs,
      cacheKey: cacheKey,
    );
  }

  Future<dynamic> _fetchDataFromApi({
    required String url,
    required SharedPreferences prefs,
    required String cacheKey,
  }) async {
    try {
      var uri = Uri.parse(url);
      String userToken = prefs.getString('userToken') ?? '';
      var response = await http.get(uri, headers: {
        'Authorization': 'Bearer $userToken',
      }).timeout(Duration(seconds: 25));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        Map<String, dynamic> cacheContent = {
          'timestamp': DateTime.now().toIso8601String(),
          'data': data,
        };
        await prefs.setString(cacheKey, json.encode(cacheContent));
        return data;
      } else {
        return json.decode(response.body);
      }
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> _getDataWithAuthHeader(String url) async {
    try {
      var uri = Uri.parse(url);
      var response = await http.post(uri, headers: {
        'Authorization': 'Bearer ${AppConstants.usertoken}',
      });
      var data = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 404) {

        return data;
      }
    } catch (e) {
      return null;
    }
  }
}
