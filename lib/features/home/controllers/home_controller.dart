import 'package:stackfood_multivendor/common/enums/data_source_enum.dart';
import 'package:stackfood_multivendor/features/home/domain/models/banner_model.dart';
import 'package:stackfood_multivendor/features/home/domain/models/cashback_model.dart';
import 'package:stackfood_multivendor/features/home/domain/services/home_service_interface.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:get/get.dart';

class HomeController extends GetxController implements GetxService {
  final HomeServiceInterface homeServiceInterface;

  HomeController({required this.homeServiceInterface});

  List<String?>? _bannerImageList;
  List<dynamic>? _bannerDataList;

  List<String?>? get bannerImageList => _bannerImageList;
  List<dynamic>? get bannerDataList => _bannerDataList;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  List<CashBackModel>? _cashBackOfferList;
  List<CashBackModel>? get cashBackOfferList => _cashBackOfferList;

  CashBackModel? _cashBackData;
  CashBackModel? get cashBackData => _cashBackData;

  bool _showFavButton = true;
  bool get showFavButton => _showFavButton;

  Future<void> getBannerList(bool reload, {DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false}) async {
    if(_bannerImageList == null || reload || fromRecall) {
      if(!fromRecall) {
        _bannerImageList = null;
      }
      BannerModel? bannerModel;
      if(dataSource == DataSourceEnum.local){
        bannerModel = await homeServiceInterface.getBannerList(source: DataSourceEnum.local);
        _prepareBannerList(bannerModel);
        getBannerList(false, dataSource: DataSourceEnum.client, fromRecall: true);
      }else{
        bannerModel = await homeServiceInterface.getBannerList(source: DataSourceEnum.client);
        _prepareBannerList(bannerModel);
      }
    }
  }

  _prepareBannerList(BannerModel? bannerModel){
    if (bannerModel != null) {
      _bannerImageList = [];
      _bannerDataList = [];
      for (var campaign in bannerModel.campaigns!) {
        _bannerImageList!.add(campaign.imageFullUrl);
        _bannerDataList!.add(campaign);
      }
      for (var banner in bannerModel.banners!) {
        if(_bannerImageList!.contains(banner.imageFullUrl)){
          _bannerImageList!.add('${banner.imageFullUrl}${bannerModel.banners!.indexOf(banner)}');
        }else {
          _bannerImageList!.add(banner.imageFullUrl);
        }
        if(banner.food != null) {
          _bannerDataList!.add(banner.food);
        }else {
          _bannerDataList!.add(banner.restaurant);
        }
      }
      if(ResponsiveHelper.isDesktop(Get.context) && _bannerImageList!.length % 3 != 0){
        _bannerImageList!.add(_bannerImageList![0]);
        _bannerDataList!.add(_bannerDataList![0]);
      }
    }
    update();
  }

  void setCurrentIndex(int index, bool notify) {
    _currentIndex = index;
    if(notify) {
      update();
    }
  }


  Future<void> getCashBackOfferList({DataSourceEnum dataSource = DataSourceEnum.local}) async {
    _cashBackOfferList = null;
    List<CashBackModel>? cashBackOfferList;

    if(dataSource == DataSourceEnum.local){
      cashBackOfferList = await homeServiceInterface.getCashBackOfferList(source: DataSourceEnum.local);
      _prepareCashBackOfferList(cashBackOfferList);
      getCashBackOfferList(dataSource: DataSourceEnum.client);
    }else{
      cashBackOfferList = await homeServiceInterface.getCashBackOfferList(source: DataSourceEnum.client);
      _prepareCashBackOfferList(cashBackOfferList);
    }
  }

  _prepareCashBackOfferList(List<CashBackModel>? cashBackOfferList){
    if(cashBackOfferList != null) {
      _cashBackOfferList = [];
      _cashBackOfferList!.addAll(cashBackOfferList);
    }
    update();
  }

  void forcefullyNullCashBackOffers() {
    _cashBackOfferList = null;
    update();
  }

  Future<void> getCashBackData(double amount) async {
    CashBackModel? cashBackModel = await homeServiceInterface.getCashBackData(amount);
    if(cashBackModel != null) {
      _cashBackData = cashBackModel;
    }
    update();
  }

  void changeFavVisibility(){
    _showFavButton = !_showFavButton;
    update();
  }

}