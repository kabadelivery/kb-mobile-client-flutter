import 'package:flutter/foundation.dart';

class _UserInformationModel {

  final int id;
  final String username;
  final String phone_number;
  final String nickname;
  final String birthday;
  final String job_title;
  final String district;
  final int gender; /* 1 female - 2 male - 3 dontwannasay - 0 notsetyet */
  final String profile_picture;
  final String theme_picture;
  final int isSet;


  _UserInformationModel({this.id, this.username, this.phone_number, this.nickname, this.birthday,
    this.job_title, this.district, this.gender, this.profile_picture, this.theme_picture,
    this.isSet=0});

  _UserInformationModel copyWith ({int id, String username, String phone_number, String nickname, String birthday,
    String job_title, String district, String gender, String profile_picture, String theme_picture,
    int isSet=0}) {

    return _UserInformationModel (
        id: id ?? this.id,
      username: username ?? this.username,
      phone_number: phone_number ?? this.phone_number,
      nickname: nickname ?? this.nickname,
      birthday: birthday ?? this.birthday,
      job_title: job_title ?? this.job_title,
      district: district ?? this.district,
      gender: gender ?? this.gender,
      profile_picture: profile_picture ?? this.profile_picture,
      theme_picture: this.theme_picture,
      isSet: this.isSet,
    );
  }

  Map toJson () => {
    "id" : (id as int),
    "username" : username,
    "phone_number" : phone_number,
    "nickname" : nickname,
    "birthday" : birthday,
    "job_title" : job_title,
    "district" : district,
    "gender" : gender,
    "profile_picture" : profile_picture,
    "theme_picture" : theme_picture,
    "isSet" : isSet,
  };

  @override
  String toString() {
    return toJson().toString();
  }


}