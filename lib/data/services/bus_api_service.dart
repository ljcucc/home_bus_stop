import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_suggestion.dart';
import '../models/api_stop_data.dart';

class BusApiService {
  static const _baseUrl = 'https://2384.tainan.gov.tw/NewTNBusAPI_V2';

  Future<List<ApiSuggestion>> searchStops(String keyword) async {
    final uri = Uri.parse('$_baseUrl/API/keyword.ashx');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'keyword': keyword, 'type': '1', 'Lang': 'cht', 'prj': 'tn'},
    );
    if (response.statusCode != 200) {
      throw Exception('搜尋站牌失敗: ${response.statusCode}');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .cast<Map<String, dynamic>>()
        .map(ApiSuggestion.fromJson)
        .toList();
  }

  Future<List<ApiStopLocation>> fetchStopData(String stopName) async {
    final uri = Uri.parse('$_baseUrl/API/CrossRoutesV2.ashx');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'stopnamecht': stopName,
        'Lang': 'cht',
        'Types': '1',
        'prj': 'tn',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('讀取站牌資料失敗: ${response.statusCode}');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .cast<Map<String, dynamic>>()
        .map(ApiStopLocation.fromJson)
        .toList();
  }
}
