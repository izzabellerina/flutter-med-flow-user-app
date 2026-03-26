class AlertModel {
  final Map data;

  AlertModel({required this.data});

  String get type => data['type'] ?? '';

  int get value => data['value'] ?? 0;

  String get message => data['message'] ?? '';

  String get severity => data['severity'] ?? '';
}
