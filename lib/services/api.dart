import 'package:dio/dio.dart';

class ConnectServer {
  static var base_url = 'http://31.128.42.158:8005/api/';
  // static var base_url = 'http://127.0.0.1:8005/api/';

  static Dio dio = Dio();

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // COMMON
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////

  static Future<List<dynamic>> auth(email, pass) async {
    String url = '${base_url}users/?email=${email}&password=${pass}';
    Response response = await dio.get(url);
    List<dynamic> responseData = response.data;
    return responseData;
  }

  static Future<Map<String, dynamic>> register(
      {email = '', phone = '', pass = ''}) async {
    var body = {'email': email, 'phone_number': phone, 'password': pass};
    String url = '${base_url}users/';
    Response response = await dio.post(url, data: body);
    Map<String, dynamic> responseData = response.data;
    return responseData;
  }

  static Future<List<dynamic>> getProducts() async {
    String url = '${base_url}products/?is_active=true';
    Response response = await dio.get(url);
    List<dynamic> responseData = response.data;
    return responseData;
  }

  static Future<Map<String, dynamic>> getProduct(String productId) async {
    String url = '${base_url}products/${productId}';
    print(url);
    Response response = await dio.get(url);
    Map<String, dynamic> responseData = response.data;
    return responseData;
  }

  static Future<List<dynamic>> searchProducts({
    String title = '',
    String condition = '',
    String sub_category = '',
    String price_min = '',
    String price_max = '',
    String region = '',
    String district = '',
    String owner_id = '',
    String sort_by = '',
    String is_active = '',
  }) async {
    String url = '${base_url}products/?';

    if (title.isNotEmpty) {
      url += 'title=$title&';
    }
    if (condition.isNotEmpty) {
      url += 'condition=$condition&';
    }
    if (sub_category.isNotEmpty) {
      url += 'sub_category=$sub_category&';
    }
    if (price_min.isNotEmpty) {
      url += 'price_min=$price_min&';
    }
    if (price_max.isNotEmpty) {
      url += 'price_max=$price_max&';
    }
    if (region.isNotEmpty) {
      url += 'region=$region&';
    }
    if (district.isNotEmpty) {
      url += 'district=$district&';
    }
    if (owner_id.isNotEmpty) {
      url += 'owner_id=$owner_id&';
    }
    if (sort_by.isNotEmpty) {
      url += 'sort_by=$sort_by&';
    }

    if (url.endsWith('&')) {
      url = url.substring(0, url.length - 1);
    }

    if (is_active == "true") {
      url += '&is_active=true&';
    }
    Response response = await dio.get(url);
    List<dynamic> responseData = response.data;
    return responseData;
  }

  static Future<List<dynamic>> getCategories() async {
    String url = '${base_url}categories/';
    Response response = await dio.get(url);
    List<dynamic> responseData = response.data;
    return responseData;
  }

  static Future<List<dynamic>> getRegions() async {
    String url = '${base_url}regions/';
    Response response = await dio.get(url);
    List<dynamic> responseData = response.data;
    return responseData;
  }

  static Future<Map<String, dynamic>> createProduct(
      Map<String, dynamic> body) async {
    String url = '${base_url}products/';
    Response response = await dio.post(url, data: body);
    Map<String, dynamic> responseData = response.data;
    return responseData;
  }

  static Future<Map<String, dynamic>> uploadProductImages(
      int productId, FormData formData) async {
    String url = '${base_url}products/$productId/upload-images/';

    final response = await dio.post(url, data: formData);
    return response.data;
  }

  static Future<String> deleteProduct(String productId) async {
    String url = '${base_url}products/${productId}/';
    Response response = await dio.delete(url);
    String responseData = response.data;
    return responseData;
  }

  static Future<String> deleteUser(String Id) async {
    String url = '${base_url}users/${Id}/';
    Response response = await dio.delete(url);
    String responseData = response.data;
    return responseData;
  }

  static Future<Map<String, dynamic>> patchProduct(
      String productId, body) async {
    String url = '${base_url}products/${productId}/';
    Response response = await dio.patch(url, data: body);
    Map<String, dynamic> responseData = response.data;
    return responseData;
  }

  static Future<Map<String, dynamic>> getUser(userId) async {
    String url = '${base_url}users/${userId}/';
    Response response = await dio.get(url);
    Map<String, dynamic> responseData = response.data;
    return responseData;
  }

  static Future<List<dynamic>> getUsers() async {
    String url = '${base_url}users/';
    Response response = await dio.get(url);
    List<dynamic> responseData = response.data;
    return responseData;
  }

  static Future<Map<String, dynamic>> patchUser(userId, FormData body) async {
    String url = '${base_url}users/${userId}/';

    Map<String, dynamic> responseData = {};
    try {
      Response response = await dio.patch(url, data: body);
      Map<String, dynamic> responseData = response.data;
    } catch (e) {}
    return responseData;
  }

  static Future<List<dynamic>> getMyChats(String userId) async {
    String url = '${base_url}conversations/?user_id=${userId}';
    Response response = await dio.get(url);
    List<dynamic> responseData = response.data;
    return responseData;
  }

  static Future<Map<String, dynamic>> getChatMessages(String chatId) async {
    String url = '${base_url}conversations/${chatId}/';
    Response response = await dio.get(url);
    Map<String, dynamic> responseData = response.data;
    return responseData;
  }

  static Future<Map<String, dynamic>> postMessages({
    String chatId = '',
    String message = '',
    String senderId = '',
  }) async {
    final Map<String, dynamic> body = {
      'conversation': chatId,
      'sender': senderId,
      'text': message
    };
    String url = '${base_url}messages/';
    Response response = await dio.post(url, data: body);
    Map<String, dynamic> responseData = response.data;
    return responseData;
  }

  static Future<List<dynamic>> getConversation(
      String chatId1, String chatId2) async {
    String url =
        '${base_url}conversations/?user_id=${chatId1}&user_id=${chatId2}';
    Response response = await dio.get(url);
    List<dynamic> responseData = response.data;
    return responseData;
  }

  static Future<Map<String, dynamic>> postConversation(
      String chatId1, String chatId2) async {
    String url = '${base_url}conversations/';
    var body = {
      "participant_ids": [int.parse(chatId1), int.parse(chatId2)]
    };
    Response response = await dio.post(url, data: body);
    Map<String, dynamic> responseData = response.data;
    return responseData;
  }

  static Future<Map<String, dynamic>> patchConversation(
      String conversationId) async {
    String url = '${base_url}conversations/${conversationId}/';
    Response response = await dio.patch(url);
    Map<String, dynamic> responseData = response.data;
    return responseData;
  }
}
