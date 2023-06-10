class Story {
  final int id;
  final String uuid;
  final String avatar;
  final String nick;
  final String data;
  final String photo;
  final String tipe;
  final String tags;
  final String btnstat;
  final String timestamp;

  Story(
      {required this.id,
        required this.uuid,
        required this.avatar,
        required this.nick,
        required this.data,
        required this.photo,
        required this.tipe,
        required this.tags,
        required this.btnstat,
        required this.timestamp});

  Story.fromJson(Map<dynamic, dynamic> json) :
        id        = json['id'],
        uuid      = json['uuid'],
        avatar    = json['avatar'],
        nick      = json['nick'],
        data      = json['data'],
        photo     = json['photo'],
        tipe      = json['tipe'],
        tags      = json['tags'],
        btnstat   = json['btnstat'],
        timestamp = json['timestamp'];

  Map<dynamic, dynamic> toJson() =>
      {
        'id'        : id,
        'uuid'      : uuid,
        'avatar'    : avatar,
        'nick'      : nick,
        'data'      : data,
        'photo'     : photo,
        'tipe'      : tipe,
        'tags'      : tags,
        'btnstat'   : btnstat,
        'timestamp' : timestamp,
      };

  @override
  String toString() {
    return 'Story{id: $id, uuid: $uuid, avatar: $avatar, nick: $nick, data: $data, photo: $photo, tipe: $tipe, tags: $tags, btnstat: $btnstat, timestamp: $timestamp}';
  }
}
