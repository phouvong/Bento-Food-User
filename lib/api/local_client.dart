import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart' as drift;
import 'package:stackfood_multivendor/common/enums/data_source_enum.dart';
import 'package:stackfood_multivendor/data_source/cache_response.dart';
import 'package:stackfood_multivendor/helper/db_helper.dart';

class LocalClient {

  static Future<String?> organize(DataSourceEnum source, String cacheId, String? responseBody, Map<String, String>? header) async {
    SharedPreferences sharedPreferences = Get.find();
    switch(source) {
      case DataSourceEnum.client:
        try{
          if(GetPlatform.isWeb) {
            await sharedPreferences.setString(cacheId, responseBody??'');
          } else {
            DbHelper.insertOrUpdate(
              id: cacheId,
              data: CacheResponseCompanion(
                endPoint: drift.Value(cacheId),
                header: drift.Value(header.toString()),
                response: drift.Value(responseBody??''),
              ),
            );
          }
        } catch(e) {
          if (kDebugMode) {
            print('=====error occure in repo add api data: $e');
          }
        }
      case DataSourceEnum.local:
        try {
          if(GetPlatform.isWeb) {
            String? cacheData = sharedPreferences.getString(cacheId);
            return cacheData;
          } else {
            final CacheResponseData? cacheResponseData = await database.getCacheResponseById(cacheId);
            return cacheResponseData?.response;
          }

        } catch (e) {
          if (kDebugMode) {
            print('=====error occur in get local data repo: $e');
          }
        }
    }
    return null;
  }
}