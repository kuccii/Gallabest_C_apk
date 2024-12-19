import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:GalaBest/features/loyalty/controllers/loyalty_controller.dart';
import 'package:GalaBest/features/loyalty/widgets/loyalty_bottom_sheet_widget.dart';
import 'package:GalaBest/features/loyalty/widgets/loyalty_card_widget.dart';
import 'package:GalaBest/features/loyalty/widgets/loyalty_history_widget.dart';
import 'package:GalaBest/features/profile/controllers/profile_controller.dart';
import 'package:GalaBest/helper/auth_helper.dart';
import 'package:GalaBest/helper/responsive_helper.dart';
import 'package:GalaBest/util/dimensions.dart';
import 'package:GalaBest/util/styles.dart';
import 'package:GalaBest/common/widgets/custom_app_bar.dart';
import 'package:GalaBest/common/widgets/footer_view.dart';
import 'package:GalaBest/common/widgets/menu_drawer.dart';
import 'package:GalaBest/common/widgets/not_logged_in_screen.dart';
import 'package:GalaBest/common/widgets/web_page_title_widget.dart';

class LoyaltyScreen extends StatefulWidget {
  const LoyaltyScreen({super.key});

  @override
  State<LoyaltyScreen> createState() => _LoyaltyScreenState();
}

class _LoyaltyScreenState extends State<LoyaltyScreen> {
  final ScrollController scrollController = ScrollController();
  final tooltipController = JustTheController();

  @override
  void initState() {
    super.initState();

    initCall();

  }

  void initCall(){
    if(AuthHelper.isLoggedIn()){

      Get.find<ProfileController>().getUserInfo();

      Get.find<LoyaltyController>().getLoyaltyTransactionList('1', false);

      Get.find<LoyaltyController>().setOffset(1);

      scrollController.addListener(() {
        if (scrollController.position.pixels == scrollController.position.maxScrollExtent
            && Get.find<LoyaltyController>().transactionList != null
            && !Get.find<LoyaltyController>().isLoading) {
          int pageSize = (Get.find<LoyaltyController>().popularPageSize! / 10).ceil();
          if (Get.find<LoyaltyController>().offset < pageSize) {
            Get.find<LoyaltyController>().setOffset(Get.find<LoyaltyController>().offset + 1);
            if (kDebugMode) {
              print('end of the page');
            }
            Get.find<LoyaltyController>().showBottomLoader();
            Get.find<LoyaltyController>().getLoyaltyTransactionList(Get.find<LoyaltyController>().offset.toString(), false);
          }
        }
      });
    }
  }
  @override
  void dispose() {
    super.dispose();

    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = AuthHelper.isLoggedIn();

    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      appBar: CustomAppBar(title: 'loyalty_points'.tr, backButton: true),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: isLoggedIn && !ResponsiveHelper.isDesktop(context) ? FloatingActionButton.extended(
        backgroundColor: Theme.of(context).primaryColor,
        label: Text( 'convert_to_wallet_money'.tr, style: robotoBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeDefault)),
        onPressed: (){
          Get.dialog(
            Dialog(backgroundColor: Colors.transparent, child: LoyaltyBottomSheetWidget(
                amount: Get.find<ProfileController>().userInfoModel!.loyaltyPoint == null ? '0' : Get.find<ProfileController>().userInfoModel!.loyaltyPoint.toString(),
            )),
          );
        },
      ) : null,
      body: GetBuilder<ProfileController>(
          builder: (profileController) {
            return isLoggedIn ? profileController.userInfoModel != null ? SafeArea(
              child: RefreshIndicator(
                onRefresh: () async{
                  Get.find<LoyaltyController>().getLoyaltyTransactionList('1', true);
                  Get.find<ProfileController>().getUserInfo();
                },
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      WebScreenTitleWidget(title: 'loyalty_points'.tr),
                      FooterView(
                        child: SizedBox(width: Dimensions.webMaxWidth,
                          child: GetBuilder<LoyaltyController>(
                              builder: (loyaltyController) {
                                return ResponsiveHelper.isDesktop(context) ? Padding(
                                  padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
                                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Expanded (flex: 4 , child: Column(children: [
                                          Container(
                                            decoration: ResponsiveHelper.isDesktop(context) ? BoxDecoration(
                                              color: Theme.of(context).cardColor,
                                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
                                            ) : null,
                                            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                                            child: LoyaltyCardWidget(tooltipController: tooltipController),
                                          ),
                                        ],
                                      )),
                                      const SizedBox(width: Dimensions.paddingSizeDefault),

                                      Expanded(flex: 6, child: Column(children: [
                                        Container(
                                          decoration: ResponsiveHelper.isDesktop(context) ? BoxDecoration(
                                            color: Theme.of(context).cardColor,
                                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
                                          ) : null,
                                          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                                          child: const LoyaltyHistoryWidget(),
                                        ),
                                      ])),
                                    ]),
                                )
                             : Column(children: [

                                Padding(
                                  padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault, left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
                                  child: LoyaltyCardWidget(tooltipController: tooltipController),
                                ),

                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                                  child: LoyaltyHistoryWidget(),
                                )

                              ]);
                            }
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ) : const Center(child: CircularProgressIndicator()) : NotLoggedInScreen(callBack: (value){
              initCall();
              setState(() {});
            });
          }
      ),
    );
  }
}