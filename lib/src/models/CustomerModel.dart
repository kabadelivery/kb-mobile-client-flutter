

class CustomerModel {

   int id;
   String username;
   String phone_number;
   String nickname;
   String birthday;
   String job_title;
   String district;
   int gender; /* 1 female - 2 male - 3 dontwannasay - 0 notsetyet */
   String profile_picture;
   String theme_picture;
   int isSet = 0;
   String token;

   CustomerModel({this.id, this.username, this.phone_number, this.nickname,
       this.birthday, this.job_title, this.district, this.gender,
       this.profile_picture, this.theme_picture, this.isSet});

   CustomerModel.fromJson(Map<String, dynamic> json) {

      id = json['id'];
      username = json['username'];
      phone_number = json['phone_number'];
      nickname = json['nickname'];
      birthday = json['birthday'];
      job_title = json['job_title'];
      district = json['district'];
      gender = json['gender'];
      profile_picture = json['profile_picture'];
      theme_picture = json['theme_picture'];
      isSet = json['isSet'];
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