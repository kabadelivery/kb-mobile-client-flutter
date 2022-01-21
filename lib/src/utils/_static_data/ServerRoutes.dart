import 'package:flutter/material.dart';
import 'package:KABA/src/utils/_static_data/ServerConfig.dart';

class ServerRoutes {

  /* update home */
  static const String LINK_HOME_PAGE = ServerConfig.SERVER_ADDRESS+
      "/api/front/get";

  /* get restaurant db */
  static const String LINK_RESTO_FOOD_DB = ServerConfig.SERVER_ADDRESS+
      "/sample/restaurant_menu_sample.json";

  /* get current command db */
  static const String LINK_MY_COMMANDS_GET_CURRENT = ServerConfig.SERVER_ADDRESS+
      "/mobile/api/command/v3/get";

  /* get all commands list */
  static const String LINK_GET_ALL_COMMAND_LIST = ServerConfig.SERVER_ADDRESS+
      "/mobile/api/command/all/v3/get";

  /* create command db */
  static const String LINK_CREATE_COMMAND = ServerConfig.SERVER_ADDRESS_SECURE +
      "/mobile/api/command/v3/create";

  /* get command details */
  static const String LINK_GET_COMMAND_DETAILS =  ServerConfig.SERVER_ADDRESS+
      "/mobile/api/command/details/v3/get";

  /* get current basket content */
  static const String LINK_MY_BASKET_GET = ServerConfig.SERVER_ADDRESS+
      "/mobile/api/basket/get";

  /* get current basket content */
  static const String LINK_MY_BASKET_CREATE = ServerConfig.SERVER_ADDRESS+
      "/mobile/api/basket/create";

  /* get current horoscope content */
  static const String LINK_MY_HOROSCOPE = ServerConfig.SERVER_ADDRESS+
      "/sample/horoscope.json";

  /* get current favorite content */
  static const String LINK_MY_FAVORITE = ServerConfig.SERVER_ADDRESS+
      "/mobile/api/getFavorites";

  /* set favorite */
  static const String LINK_SET_FAVORITE = ServerConfig.SERVER_ADDRESS + "/mobile/api/setFavorite";

  /* get current adresses content */
  static const String LINK_GET_ADRESSES = ServerConfig.SERVER_ADDRESS+
      "/mobile/api/getAdresses";

  /* create new adresses content */
  static const String LINK_CREATE_NEW_ADRESS = ServerConfig.SERVER_ADDRESS+
      "/mobile/api/createV2Adresses";

  /* search customer with no */
  static const String LINK_SEARCH_CUSTOMER = ServerConfig.SERVER_ADDRESS+
      "/mobile/api/searchAdresses";

  static const String LINK_TRANSFER_ADDRESS = ServerConfig.SERVER_ADDRESS+
      "/mobile/api/user/address/send";

  /* delete address */
  static const String LINK_DELETE_ADRESS = ServerConfig.SERVER_ADDRESS+
      "/mobile/api/deleteV2Adresses";

  /* accept incoming address */
  static const String LINK_ACCEPT_INCOMING_ADDRESS = ServerConfig.SERVER_ADDRESS+
      "/mobile/api/user/address/accept";

  /* refuse incoming address */
  static const String LINK_REFUSE_INCOMING_ADDRESS = ServerConfig.SERVER_ADDRESS+
      "/mobile/api/user/address/refuse";

  /* toggle receiving incoming address */
  static const String LINK_TOGGLE_ACCEPT_INCOMING_ADDRESS = ServerConfig.SERVER_ADDRESS+
      "/mobile/api/receive_address/toggle";

  /* get current account informations */
  static const String LINK_MY_ACCOUNT_INFO = ServerConfig.SERVER_ADDRESS+
      "/sample/useraccount.json";

  /* menu food*/
  static const String LINK_MENU_BY_RESTAURANT_ID = ServerConfig.SERVER_ADDRESS+
      "/api/menu/get";

  static const String LINK_MENU_BY_ID = ServerConfig.SERVER_ADDRESS+
      "/api/menu/get/id";

  static const String LINK_RESTO_LIST = ServerConfig.SERVER_ADDRESS+
      "/api/restaurant/get";

  static const String LINK_RESTO_LIST_V2 = ServerConfig.SERVER_ADDRESS+
      "/api/restaurant/v2/get";

  /* user login */
  // static const String LINK_USER_LOGIN =  ServerConfig.SERVER_ADDRESS_SECURE+
  //     "/mobile/api/login_check";

  static const String LINK_USER_LOGIN_V2 =  ServerConfig.SERVER_ADDRESS_SECURE+
      "/api/user/login";

  static const String LINK_USER_LOGIN_V3 =  ServerConfig.SERVER_ADDRESS_SECURE+
      "/api/user/otp-login";

  /* user register */
  static const String LINK_USER_REGISTER =  ServerConfig.SERVER_ADDRESS_SECURE+
      "/api/user/register";

  /* register push token */
  static const String LINK_REGISTER_PUSH_TOKEN = ServerConfig.SERVER_ADDRESS+
      "/api/device/add";

  /* update phone / user push_token */
//  static const String LINK_PHONE_UPDATE_SERVER_PUSH_TOKEN = ServerConfig.SERVER_ADDRESS+"/mobile/api/update_client_push_token";

  /* get notification food data */
  static const String LINK_NOTIFICATION_FOOD_DATA =  ServerConfig.SERVER_ADDRESS+
      "/notification/food";

  /* get notification menu data */
  static const String LINK_NOTIFICATION_RESTAURANT_DATA = ServerConfig.SERVER_ADDRESS+
      "/notification/restaurant";

  /* get notification menu data */
  static const String LINK_NOTIFICATION_MENU_DATA = ServerConfig.SERVER_ADDRESS+
      "/notification/menu";

  /* delete basket item */
  static const String LINK_MY_BASKET_DELETE = ServerConfig.SERVER_ADDRESS+
      "/mobile/api/basket/delete";

  /* update user informations */
  static const String LINK_UPDATE_USER_INFORMATIONS = ServerConfig.SERVER_ADDRESS+
      "/mobile/api/user/change";

  /* get article informations */
  static const String LINK_ARTICLE_INFORMATIONS = ServerConfig.SERVER_ADDRESS+
      "/api/article/get";

  /* get position details */
  static const String LINK_GET_LOCATION_DETAILS = ServerConfig.SERVER_ADDRESS+
      "/mobile/api/district/get";

  static const String LINK_CHECK_RESTAURANT_IS_OPEN = ServerConfig.SERVER_ADDRESS+
      "/api/resto/state/get";

  static const String LINK_COMPUTE_BILLING = ServerConfig.SERVER_ADDRESS+
      "/mobile/api/commandBilling/v3/get";

  static const String LINK_GET_LASTEST_FEEDS = ServerConfig.SERVER_ADDRESS+
      "/mobile/api/feeds/get";

    static String LINK_GET_CUSTOMER_SERVICE_ALL_MESSAGES = ServerConfig.SERVER_ADDRESS+
        "/mobile/api/user/get/discussion";

  static const String LINK_SEND_VERIFCATION_SMS = ServerConfig.SERVER_ADDRESS+
      "/api/code/request";

  static const String LINK_SEND_VERIFCATION_EMAIL_SMS = ServerConfig.SERVER_ADDRESS+
      "/api/code/request";   //"/api/code/request/mail";

  static const String LINK_SEND_RECOVER_VERIFCATION_SMS = ServerConfig.SERVER_ADDRESS+
      "/api/password/code/request";

  static const String LINK_POST_SUGGESTION = ServerConfig.SERVER_ADDRESS +
      "/mobile/api/add/suggestion";

  static const String LINK_GET_BESTSELLERS_LIST = ServerConfig.SERVER_ADDRESS +
      "/api/food/rating/get";

  /* get notification food data */
  static const String LINK_GET_FOOD_DETAILS_LOGGED =  ServerConfig.SERVER_ADDRESS+
      "/mobile/api/food/details/get";

  static const String LINK_GET_FOOD_DETAILS_SIMPLE =  ServerConfig.SERVER_ADDRESS+
      "/api/food/details/get";

  static const String LINK_SEARCH_FOOD_BY_TAG = ServerConfig.SERVER_ADDRESS +
      "/api/food/search";

  static const String LINK_GET_EVENEMENTS_LIST = ServerConfig.SERVER_ADDRESS +
      "/api/event/get";

  static const String LINK_CHECK_VERIFCATION_CODE = ServerConfig.SERVER_ADDRESS +
      "/api/code/check";

  static const String LINK_CHECK_RECOVER_VERIFCATION_CODE = ServerConfig.SERVER_ADDRESS +
      "/api/password/code/check";

  static const String LINK_GET_RESTAURANT_REVIEWS = ServerConfig.SERVER_ADDRESS +
      "/mobile/api/comment/get";

  /* Review - */
  static const String LINK_POST_COMMENT =  ServerConfig.SERVER_ADDRESS +
      "/mobile/api/comment/add";

  static const String LINK_GET_RESTAURANT_DETAILS = ServerConfig.SERVER_ADDRESS +
      "/api/find/restaurant";

  static const String LINK_TRY_LOGOUT = ServerConfig.SERVER_ADDRESS +"/mobile/api/logout_client_device";

  static const String LINK_CHECK_CAN_COMMENT = ServerConfig.SERVER_ADDRESS +"/mobile/api/canComment";

  /* pay addresses */
  static const String LINK_GET_TRANSACTION_HISTORY = ServerConfig.PAY_SERVER_ADDRESS_SECURE +
      "/mobile/api/user/transaction/history";

  static const String LINK_GET_BALANCE =  ServerConfig.PAY_SERVER_ADDRESS_SECURE +
      "/mobile/api/user/transaction/balance/get";

  static const String GET_KABA_POINTS = ServerConfig.SERVER_ADDRESS+"/mobile/api/user/kaba/point/get";

  static const String FAQ_PAGE = ServerConfig.SERVER_ADDRESS+"/page/faq";

  static const String CGU_PAGE = ServerConfig.SERVER_ADDRESS+"/page/cgu";

  // vouchers
//  static const String LINK_GET_MY_VOUCHERS = ServerConfig.SERVER_ADDRESS+"/mobile/api/voucher/all";

  /* top up */
  static const String LINK_GET_TOPUP_CHOICES = LINK_HOME_PAGE;

  /* flooz top up */
  static const String LINK_TOPUP_FLOOZ = ServerConfig.PAY_SERVER_ADDRESS_SECURE+"/mobile/api/sms/payment/init";

  /* t-money top up */
  static const String LINK_TOPUP_TMONEY = ServerConfig.PAY_SERVER_ADDRESS_SECURE+"/mobile/api/web/payment/init";

  static const String LINK_TOPUP_PAYDUNYA = ServerConfig.PAY_SERVER_ADDRESS_SECURE+ "/mobile/api/bankcard/payment/init";

  /* reset password */
  static const String LINK_PASSWORD_RESET = ServerConfig.SERVER_ADDRESS_SECURE+"/api/password/reset";
  
//  static const String common_server_address = "";

  // money transfer check customer identity
  static const  String LINK_CHECK_USER_ACCOUNT = ServerConfig.SERVER_ADDRESS_SECURE+"/mobile/api/user/username/valid/check";

  // money transfer interface
  static const  String LINK_MONEY_TRANSFER = ServerConfig.SERVER_ADDRESS_SECURE+"/mobile/api/user/send/credit";

  /* get sponsorship configuration */
  static const  String LINK_GET_SPONSORSHIP_CODE = ServerConfig.SERVER_ADDRESS_SECURE+"/mobile/api/user/sponsorshipcode/get";

  /* get sponsored */
  static const  String LINK_GET_SPONSORED = ServerConfig.SERVER_ADDRESS+"/mobile/api/user/sponsor";

  /* get sponsorship stats */
  static const  String LINK_GET_LAST_SPONSORSHIP_FEEDS = ServerConfig.SERVER_ADDRESS+"/mobile/api/user/last/sponsorship/get";

  static const  String LINK_GET_ALL_SPONSORSHIP_HISTORY = ServerConfig.SERVER_ADDRESS +"/mobile/api/user/all/sponsorship/get" ;

  static const  String LINK_CHECK_SPONSORSHIP_ENABLED = ServerConfig.SERVER_ADDRESS+"/mobile/api/user/sponsoring/enabled/check";

  static const String LINK_SEND_ORDER_FEEDBACK = ServerConfig.SERVER_ADDRESS +"/mobile/api/command/delivery/rate";

  static const String  LINK_TOPUP_FEES_RATE = ServerConfig.SERVER_ADDRESS_SECURE+"/api/fees/get";

  static const String  LINK_TOPUP_FEES_RATE_V2 = ServerConfig.SERVER_ADDRESS_SECURE+"/api/fees/get/v2";

  static const String  LINK_CHECK_UNREAD_MESSAGES = ServerConfig.SERVER_ADDRESS_SECURE+"/mobile/api/user/new/message/check";

  static const String  LINK_GET_MY_VOUCHERS = ServerConfig.SERVER_ADDRESS+"/mobile/api/vouchers/get";

  static const String  LINK_GET_VOUCHERS_FOR_ORDER = ServerConfig.SERVER_ADDRESS+"/mobile/api/vouchers/valid/get";

  static const String  LINK_SUBSCRIBE_VOUCHERS = ServerConfig.SERVER_ADDRESS+"/mobile/api/vouchers/subscribe";

  static const String LINK_CHECK_APP_VERSION = ServerConfig.SERVER_ADDRESS+"/api/ltsapp/get";

  static const String LINK_CHECK_SYS_MESSAGE = ServerConfig.SERVER_ADDRESS+"/api/alert-message/get";

}
