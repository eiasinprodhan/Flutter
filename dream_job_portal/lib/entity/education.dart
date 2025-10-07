class Education {
  int? id;
  String? level;
  String? institute;
  String? board;
  String? result;
  String? year;

  Education(
      {this.id,
        this.level,
        this.institute,
        this.board,
        this.result,
        this.year});

  Education.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    level = json['level'];
    institute = json['institute'];
    board = json['board'];
    result = json['result'];
    year = json['year'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['level'] = this.level;
    data['institute'] = this.institute;
    data['board'] = this.board;
    data['result'] = this.result;
    data['year'] = this.year;
    return data;
  }
}
