import 'package:stackfood_multivendor/common/enums/data_source_enum.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/features/product/domain/models/basic_campaign_model.dart';
import 'package:stackfood_multivendor/features/product/domain/repositories/campaign_repository_interface.dart';
import 'package:stackfood_multivendor/features/product/domain/services/campaign_service_interface.dart';

class CampaignService implements CampaignServiceInterface {
  final CampaignRepositoryInterface campaignRepositoryInterface;

  CampaignService({required this.campaignRepositoryInterface});

  @override
  Future<List<BasicCampaignModel>?> getBasicCampaignList() async {
    return await campaignRepositoryInterface.getList(basicCampaign: true);
  }

  @override
  Future<List<Product>?> getItemCampaignList({DataSourceEnum? source}) async {
    return await campaignRepositoryInterface.getList(source: source);
  }

  @override
  Future<BasicCampaignModel?> getCampaignDetails(String campaignID) async {
    return await campaignRepositoryInterface.get(campaignID);
  }

}