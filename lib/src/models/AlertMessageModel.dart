class AlertMessageModel {

  final int id;
  final String title;
  final int showAlert;
  final Map messages;
  final int error;
  final String uuid;

//<editor-fold desc="Data Methods">

  const AlertMessageModel({
     this.id,
     this.title,
     this.showAlert,
     this.messages,
     this.error,
     this.uuid,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AlertMessageModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          showAlert == other.showAlert &&
          messages == other.messages &&
          error == other.error &&
          uuid == other.uuid);

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      showAlert.hashCode ^
      messages.hashCode ^
      error.hashCode ^
      uuid.hashCode;

  @override
  String toString() {
    return 'AlertMessageModel{' +
        ' id: $id,' +
        ' title: $title,' +
        ' showAlert: $showAlert,' +
        ' messages: $messages,' +
        ' error: $error,' +
        ' uuid: $uuid,' +
        '}';
  }

  AlertMessageModel copyWith({
    int id,
    String title,
    int showAlert,
    Map messages,
    int error,
    String uuid,
  }) {
    return AlertMessageModel(
      id: id ?? this.id,
      title: title ?? this.title,
      showAlert: showAlert ?? this.showAlert,
      messages: messages ?? this.messages,
      error: error ?? this.error,
      uuid: uuid ?? this.uuid,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'title': this.title,
      'showAlert': this.showAlert,
      'messages': this.messages,
      'error': this.error,
      'uuid': this.uuid,
    };
  }

  factory AlertMessageModel.fromMap(Map<String, dynamic> map) {
    return AlertMessageModel(
      id: map['id'] as int,
      title: map['title'] as String,
      showAlert: map['showAlert'] as int,
      messages: map['messages'] as Map,
      error: map['error'] as int,
      uuid: map['uuid'] as String,
    );
  }

//</editor-fold>
}