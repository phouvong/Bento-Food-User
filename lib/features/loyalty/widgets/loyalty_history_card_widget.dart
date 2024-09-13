import 'package:stackfood_multivendor/features/wallet/domain/models/wallet_model.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class LoyaltyHistoryCardWidget extends StatelessWidget {
  final int index;
  final List<Transaction>? data;
  const LoyaltyHistoryCardWidget({super.key, required this.index, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [

              Image.asset(Images.loyaltyIcon, height: 18, width: 18),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),

              Text(
                data![index].transactionType == 'point_to_wallet'? '- ${data![index].debit!.toStringAsFixed(0)}'
                  : '+ ${data![index].credit!.toStringAsFixed(0)}',
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault), maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
            ]),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            Text(
              data![index].transactionType == 'add_fund' ? '${'added_via'.tr} ${data![index].reference!.replaceAll('_', ' ')} ${data![index].adminBonus != 0 ? '(${'bonus'.tr} = ${data![index].adminBonus})' : '' }'
                  : data![index].transactionType == 'partial_payment' ? '${'spend_on_order'.tr} # ${data![index].reference}'
                  : data![index].transactionType == 'loyalty_point' ? 'converted_from_loyalty_point'.tr
                  : data![index].transactionType == 'referrer' ? 'earned_by_referral'.tr
                  : data![index].transactionType == 'order_place' ? '${'order_place'.tr} # ${data![index].reference}'
                  : data![index].transactionType!.tr,
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall,color: Theme.of(context).hintColor),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
          ]),

          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(
              DateConverter.onlyDate(data![index].createdAt!),
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall,color: Theme.of(context).hintColor),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            Text(
              data![index].transactionType == 'point_to_wallet' ? 'debit'.tr : 'credit'.tr,
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: data![index].transactionType == 'point_to_wallet' ? Colors.red : Colors.green),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
          ]),

        ]),

      index == data!.length-1 ? const SizedBox() : Padding(
        padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
        child: Divider(color: Theme.of(context).disabledColor),
      ),

    ]);
  }
}
