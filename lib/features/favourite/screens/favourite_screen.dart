import 'package:GalaBest/common/widgets/web_page_title_widget.dart';
import 'package:GalaBest/features/splash/controllers/splash_controller.dart';
import 'package:GalaBest/features/favourite/controllers/favourite_controller.dart';
import 'package:GalaBest/helper/auth_helper.dart';
import 'package:GalaBest/helper/responsive_helper.dart';
import 'package:GalaBest/util/dimensions.dart';
import 'package:GalaBest/util/styles.dart';
import 'package:GalaBest/common/widgets/custom_app_bar.dart';
import 'package:GalaBest/common/widgets/menu_drawer.dart';
import 'package:GalaBest/common/widgets/not_logged_in_screen.dart';
import 'package:GalaBest/features/favourite/widgets/fav_item_view_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  FavouriteScreenState createState() => FavouriteScreenState();
}

class FavouriteScreenState extends State<FavouriteScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);

    initCall();
  }

  void initCall(){
    if(AuthHelper.isLoggedIn()) {
      Get.find<FavouriteController>().getFavouriteList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'favourite'.tr, backButton: false),
      endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      body: AuthHelper.isLoggedIn() ? SafeArea(child: Column(children: [

        WebScreenTitleWidget(title: 'favourite'.tr),

        SizedBox(
          width: Dimensions.webMaxWidth,
          child: Container(
            width: Dimensions.webMaxWidth,
            color: Theme.of(context).cardColor,
            alignment: Alignment.bottomLeft,
            child: TabBar(
              tabAlignment: ResponsiveHelper.isDesktop(context) ? TabAlignment.start : null,
              isScrollable: ResponsiveHelper.isDesktop(context) ? true : false,
              controller: _tabController,
              indicatorColor: Theme.of(context).primaryColor,
              indicatorWeight: 3,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Theme.of(context).disabledColor,
              unselectedLabelStyle: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
              labelStyle: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
              tabs: [
                Tab(text: 'item'.tr),
                Tab(text: Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText!
                    ? 'restaurants'.tr : 'stores'.tr),
              ],
            ),
          ),
        ),

        Expanded(child: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            FavItemViewWidget(isStore: false),
            FavItemViewWidget(isStore: true),
          ],
        )),

      ])) : NotLoggedInScreen(callBack: (value){
        initCall();
        setState(() {});
      }),
    );
  }
}