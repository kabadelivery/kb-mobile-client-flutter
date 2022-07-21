class ServiceMainEntity {

  String lottie_file_link;
  int category_id;
  String category_name;
  int state;

  ServiceMainEntity(
      {this.lottie_file_link,
      this.category_id,
      this.category_name,
      this.state});

  Map<String, dynamic> toJson() {
    return {
      "lottie_file_link": this.lottie_file_link,
      "category_id": this.category_id,
      "category_name": this.category_name,
      "state": this.state,
    };
  }

  factory ServiceMainEntity.fromJson(Map<String, dynamic> json) {
    return ServiceMainEntity(
      lottie_file_link: json["lottie_file_link"],
      category_id: int.parse(json["category_id"]),
      category_name: json["category_name"],
      state: int.parse(json["state"]),
    );
  }
//

}