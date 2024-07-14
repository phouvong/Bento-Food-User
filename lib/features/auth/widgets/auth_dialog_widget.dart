import 'package:stackfood_multivendor/features/auth/widgets/sign_in_widget.dart';
import 'package:stackfood_multivendor/features/auth/widgets/sign_up_widget.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthDialogWidget extends StatefulWidget {
  final bool exitFromApp;
  final bool backFromThis;
  const AuthDialogWidget({super.key, required this.exitFromApp, required this.backFromThis});

  @override
  AuthDialogWidgetState createState() => AuthDialogWidgetState();
}

class AuthDialogWidgetState extends State<AuthDialogWidget>  with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Tab> _tabs = <Tab>[ Tab(text: 'login'.tr), Tab(text: 'sign_up'.tr) ];
  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 780, width: 650,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Dialog(
            shadowColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            insetPadding: EdgeInsets.zero,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                Align(
                  alignment: Alignment.topRight,
                  child: InkWell(
                    onTap: (){
                      Get.back();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).cardColor.withOpacity(0.5),
                      ),
                      padding: const EdgeInsets.all(3),
                      child: const Icon(Icons.clear),
                    ),
                  ),
                ),

                Center(
                  child: Container(
                    height: constraints.minHeight - 100, width: 650,
                    margin:  const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    decoration: context.width > 700 ? BoxDecoration(
                      color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                      boxShadow: null,
                    ) : null,
                    child: SingleChildScrollView(
                      child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [

                        const SizedBox(height: 60),
                        Image.asset(Images.logo, width: 60),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        Image.asset(Images.logoName, width: 80),
                        const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                          child: TabBar(
                            tabAlignment: TabAlignment.start,
                            controller: _tabController,
                            indicatorColor: Theme.of(context).primaryColor,
                            indicatorWeight: 3,
                            labelColor: Theme.of(context).primaryColor,
                            unselectedLabelColor: Theme.of(context).disabledColor,
                            unselectedLabelStyle: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
                            labelStyle: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                            indicatorPadding: const EdgeInsets.symmetric(horizontal: 10),
                            isScrollable: true,
                            indicatorSize: TabBarIndicatorSize.tab,
                            tabs: _tabs,
                            physics: const NeverScrollableScrollPhysics(),
                            dividerColor: Theme.of(context).primaryColor.withOpacity(0.0),
                            onTap: (int ? value) {
                              setState(() {
                                _tabController.index = value!;
                              });
                            },
                          ),
                        ),

                        Padding(
                          padding : const EdgeInsets.symmetric(horizontal : Dimensions.paddingSizeOverLarge),
                          child: Column( children: [
                            SizedBox (
                              height : _tabController.index == 1 ? 520 : 520,
                              child: TabBarView(
                                controller: _tabController,
                                physics: const NeverScrollableScrollPhysics(),
                                children: const [
                                  SignInWidget(exitFromApp: true, backFromThis: true),
                                  SingleChildScrollView(child: SignUpWidget()),
                                ],
                              ),
                            ),
                          ]
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }
}
