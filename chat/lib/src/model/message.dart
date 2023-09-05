class Message {
  String? get id => _id;
  final String? from;
  final String? to;
  final DateTime? timestamp;
  final String? contents;
  String? _id;
  String? groupId;

  Message(
      {required this.from,
      required this.to,
      required this.timestamp,
      required this.contents,
      this.groupId});

  toJson() => {
        'from': from,
        'to': to,
        'timestamp': timestamp,
        'contents': contents,
        'group_id': groupId
      };

  factory Message.fromJson(Map<String, dynamic> json) {
    var message = Message(
        from: json['from'],
        to: json['to'],
        contents: json['contents'],
        timestamp: json['timestamp'],
        groupId: json['group_id']);

    message._id = json['id'];
    return message;
  }
}