class ServiceMainEntity {
  int id;
  String lottie_file_link;
  int category_id;
  Map<String, dynamic> name;
  int state;
  String key;
  int position;
  int is_coming_soon;
  int is_active;
  int is_new;

  ServiceMainEntity(
      {this.lottie_file_link,
      this.id,
      this.position,
      this.key,
      this.is_coming_soon,
      this.is_new,
      this.is_active,
      this.category_id,
      this.name,
      this.state});

  Map<String, dynamic> toJson() {
    return {
      "id": this.id,
      "lottie_file_link": this.lottie_file_link,
      "category_id": this.category_id,
      "name": this.name,
      "state": this.state,
      "key": this.key,
      "position": this.position,
      "is_coming_soon": this.is_coming_soon,
      "is_new": this.is_new,
      "is_active": this.is_active,
    };
  }

  factory ServiceMainEntity.fromJson(Map<String, dynamic> json) {
    return ServiceMainEntity(
      id: json["id"],
      lottie_file_link: json["lottie_file_link"],
      category_id: json["category_id"],
      name: json["name"],
      state: json["state"],
      key: json["key"],
      position: json["position"],
      is_coming_soon: json["is_coming_soon"],
      is_new: json["is_new"],
      is_active: json["is_active"],
    );
  }
//

}
