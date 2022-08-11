class ShopScheduleModel {
  int day;
  int open;
  int pause;
  String start;
  String end;

  ShopScheduleModel({this.day, this.open, this.pause, this.start, this.end});

  ShopScheduleModel.fromJson(Map<String, dynamic> json) {
    day = json['day'];
    open = json['open'];
    pause = json['pause'];
    start = json['start'];
    end = json['end'];
  }

  Map<String, dynamic> toJson() {
    return {
      "day": this.day,
      "open": this.open,
      "pause": this.pause,
      "start": this.start,
      "end": this.end,
    };
  }


  @override
  String toString() {
    return toJson().toString();
  }


}
