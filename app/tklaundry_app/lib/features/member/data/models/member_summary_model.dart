class MemberSummaryModel {
  const MemberSummaryModel({
    required this.userId,
    required this.userName,
    required this.useYn,
    this.loginDate,
    this.insertDate,
    this.updateDate,
  });

  factory MemberSummaryModel.fromJson(Map<String, dynamic> json) {
    return MemberSummaryModel(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      useYn: json['useYn'] as String? ?? 'Y',
      loginDate: json['loginDate'] as String?,
      insertDate: json['insertDate'] as String?,
      updateDate: json['updateDate'] as String?,
    );
  }

  final String userId;
  final String userName;
  final String useYn;
  final String? loginDate;
  final String? insertDate;
  final String? updateDate;

  bool get isActive => useYn.toUpperCase() == 'Y';
}
