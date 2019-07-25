

class ProductAdvertItem {


  int id;
  String img_path;
  int cloo;
  String ad_code;
  String ad_hash;
  String expire_date;

  ProductAdvertItem({this.id, this.img_path, this.cloo, this.ad_code,
      this.ad_hash, this.expire_date});


  ProductAdvertItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    img_path = json['img_path'];
    cloo = json['cloo'];
    ad_code = json['ad_code'];
    ad_hash = json['ad_hash'];
    expire_date = json['expire_date'];
  }


  Map toJson () => {
    "id" : (id as int),
    "img_path" : img_path,
    "cloo" : cloo,
    "ad_code" : ad_code,
    "ad_hash" : ad_hash,
    "expire_date" : expire_date,
  };

  @override
  String toString() {
    return toJson().toString();
  }

}