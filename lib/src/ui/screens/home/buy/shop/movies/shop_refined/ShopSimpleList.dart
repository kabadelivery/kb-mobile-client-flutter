import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/contracts/restaurant_list_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/ShopModel.dart';
import 'package:KABA/src/ui/customwidgets/MyLoadingProgressWidget.dart';
import 'package:KABA/src/ui/customwidgets/ShopListWidget.dart';
import 'package:KABA/src/ui/screens/message/ErrorPage.dart';
import 'package:KABA/src/xrint.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShopSimpleList extends StatefulWidget {
  static var routeName = "/ShopSimpleList";

  List<ShopModel> data;
  RestaurantListPresenter restaurantListPresenter;
  CustomerModel customer;
  String type;
  String search_key;

  ShopSimpleList(
      {Key key,
      this.customer,
      this.type,
      this.restaurantListPresenter,
      this.data,
      this.search_key})
      : super(key: key);

  @override
  State<ShopSimpleList> createState() => _ShopSimpleListState();
}

class _ShopSimpleListState extends State<ShopSimpleList>
    implements RestaurantListView {
  bool isLoading = true;
  bool hasNetworkError = false;
  bool hasSystemError = false;

  List<ShopModel> visibleItems = [];

  final ScrollController _controller = ScrollController();

  bool _isBottomLoading = false;

  int PAGE_SIZE = 10;

  @override
  void initState() {
    _controller.addListener(_onScroll);
    super.initState();
    //   launch the presenter here
    widget.restaurantListPresenter.restaurantListView = this;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _onScroll() {
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange) {
      if (hasMoreData()) {
        setState(() {
          _isBottomLoading = true;
        });
        loadMore();
      } else {
        setState(() {
          _isBottomLoading = false;
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // if (mounted) {
    widget.restaurantListPresenter.fetchShopList(
        widget.customer,
        widget.type,
        StateContainer.of(context).location,
        false, // silently
        widget.search_key);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
          child: isLoading
              ? Center(child: MyLoadingProgressWidget())
              : (hasNetworkError
                  ? _buildNetworkErrorPage()
                  : hasSystemError
                      ? _buildSysErrorPage()
                      : _buildRestaurantList(widget.data))),
    );
  }

  @override
  void inflateRestaurants(List<ShopModel> restaurants) {
    setState(() {
      widget.data = restaurants;
      visibleItems =
          (widget?.data?.length != null && widget?.data?.length > PAGE_SIZE
              ? widget.data.sublist(0, PAGE_SIZE)
              : widget.data);
    });
  }

  loadMore() async {
    await new Future.delayed(new Duration(seconds: 2));
    if (widget?.data?.length == null) {
      // empty list
    } else {
      if (visibleItems?.length == widget?.data?.length) {
        // end of the list
      } else {
        // append
        setState(() {
          visibleItems.addAll(widget.data.sublist(
              visibleItems.length,
              visibleItems.length + PAGE_SIZE >= widget.data.length
                  ? widget.data.length
                  : visibleItems.length + PAGE_SIZE));
        });
        PAGE_SIZE+=10;
      }
    }
    setState(() {
      _isBottomLoading = false;
    });
  }

  bool hasMoreData() {
    return visibleItems?.length < widget?.data?.length &&
        widget?.data?.length != null;
  }

  @override
  void loadRestaurantListLoading(bool mIsLoading) {
    setState(() {
      hasNetworkError = false;
      hasSystemError = false;
      isLoading = mIsLoading;
    });
  }

  @override
  void networkError([bool silently]) {
    // if (!silently && widget.restaurantList?.length != null && widget.restaurantList.length>0)
    if (!silently || widget?.data?.length == 0)
      setState(() {
        hasNetworkError = true;
      });
  }

  @override
  void systemError([bool silently]) {
    if (!silently || widget?.data?.length == 0)
      setState(() {
        hasSystemError = true;
      });
  }

  _buildRestaurantList(List<ShopModel> restaurantList) {
    //   build with progression
    return ListView.builder(
      controller: _controller,
      itemCount: // check if there is still room, then _isBottomLoading==true
          /* hasMoreData() && _isBottomLoading
              ? visibleItems.length + 1
              : */
          visibleItems.length + 1,
      itemBuilder: (context, position) {
        if (position == visibleItems?.length) {
          if (hasMoreData()) {
            return Container(
                width: MediaQuery.of(context).size.width,
                height: 100,
                child: Center(child: CircularProgressIndicator()));
          } else {
            return Container(
                width: MediaQuery.of(context).size.width,
                height: 100,
                child: Center(child: Text("-- The end ---")));
          }
        } else {
          return ShopListWidget(shopModel: visibleItems[position]);
        }
      },
    );
  }

  _buildSysErrorPage() {
    return ErrorPage(
        message: "${AppLocalizations.of(context).translate('system_error')}",
        onClickAction: () {
          widget.restaurantListPresenter.fetchShopList(widget.customer,
              widget.type, StateContainer.of(context).location);
        });
  }

  _buildNetworkErrorPage() {
    return ErrorPage(
        message: "${AppLocalizations.of(context).translate('network_error')}",
        onClickAction: () {
          widget.restaurantListPresenter.fetchShopList(widget.customer,
              widget.type, StateContainer.of(context).location);
        });
  }

  @override
  void inflateFilteredRestaurants(List<ShopModel> shops, String sKey) {}

}
