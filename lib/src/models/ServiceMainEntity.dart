class ServiceMainEntity {
  int id;
  int category_id;
  Map<String, dynamic> name;
  int state;
  String key;
  int position;
  int is_coming_soon;
  int is_active;
  int is_new;
  int is_lottie_file;
  String file_link;

  ServiceMainEntity(
      {
      this.id,
      this.position,
      this.key,
      this.is_coming_soon,
      this.is_new,
      this.is_active,
      this.category_id,
      this.is_lottie_file,
      this.file_link,
      this.name,
      this.state});

  Map<String, dynamic> toJson() {
    return {
      "id": this.id,
      "category_id": this.category_id,
      "name": this.name,
      "state": this.state,
      "key": this.key,
      "position": this.position,
      "is_coming_soon": this.is_coming_soon,
      "is_new": this.is_new,
      "is_active": this.is_active,
      "is_lottie_file": this.is_lottie_file,
      "file_link": this.file_link,
    };
  }

  factory ServiceMainEntity.fromJson(Map<String, dynamic> json) {
    return ServiceMainEntity(
      id: json["id"],
      category_id: json["category_id"],
      name: json["name"],
      state: json["state"],
      key: json["key"],
      position: json["position"],
      is_coming_soon: json["is_coming_soon"],
      is_new: json["is_new"],
      is_active: json["is_active"],
      file_link: json["file_link"],
      is_lottie_file: json["is_lottie_file"],
    );
  }
//

}
