import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/ShopProductModel.dart';
import 'package:KABA/src/resources/menu_api_provider.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:KABA/src/xrint.dart';

class ProposalContract {
//  void Proposal (String password, String phoneCode){}
//  Map<ShopProductModel, int> food_selected, adds_on_selected;
//  void computeBilling (CustomerModel customer, Map<ShopProductModel, int> foods, DeliveryAddressModel address){}
  void fetchProposal(CustomerModel customer) {}
}

class ProposalView {
  void showLoading(bool isLoading) {}

  void systemError() {}

  void networkError() {}

  void inflateProposal(List<ShopProductModel> proposals) {}
}

/* Proposal presenter */
class ProposalPresenter implements ProposalContract {
  bool isWorking = false;

  ProposalView _proposalView;

  late MenuApiProvider provider;

  ProposalPresenter(this._proposalView) {
    provider = new MenuApiProvider();
  }

  set proposalView(ProposalView value) {
    _proposalView = value;
  }

  @override
  Future fetchProposal(CustomerModel customer) async {
    /* fetch the one store in the local file first */

    if (isWorking) return;
    isWorking = true;

    CustomerUtils.getOldProposalPage().then((pageJson) async {
      _proposalView.showLoading(true);
      try {
        if (pageJson != null) {
          Iterable lo = mJsonDecode(pageJson)["data"];
          List<ShopProductModel>? proposals =
              lo?.map((bs) => ShopProductModel.fromJson(bs))?.toList();
          /* send these to json */
          _proposalView.inflateProposal(proposals!);
          _proposalView.showLoading(false);
        } else {
          _proposalView.showLoading(true);
        }
      } catch (_) {
        xrint(_);
        _proposalView.showLoading(true);
      }

      // at each order, make sure we reload best sellers.
      bool canLoadProposal = await CustomerUtils.canLoadProposal();
      if (!canLoadProposal) {
        isWorking = false;
        return;
      }

      try {
        String proposals_json = await provider.fetchProposalList(customer);
        // save best seller json
        // also get the restaurant entity here.
        Iterable lo = mJsonDecode(proposals_json)["data"];
        List<ShopProductModel>? proposals =
            lo?.map((bs) => ShopProductModel.fromJson(bs))?.toList();
        /* send these to json */
        CustomerUtils.saveProposalPage(proposals_json);
        CustomerUtils.saveProposalVersion(); // date
        _proposalView.showLoading(false);
        _proposalView.inflateProposal(proposals!);
        isWorking = false;
      } catch (_) {
        /* Proposal failure */
        xrint("error ${_}");
        if (_ == -2) {
          _proposalView.systemError();
        } else {
          _proposalView.networkError();
        }
        isWorking = false;
      }

    });
  }
}
