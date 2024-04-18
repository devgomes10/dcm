class ErrorModel {
  String errorCode;
  String mainDescription;
  String detailing;
  bool isActive;

  ErrorModel({
    required this.errorCode,
    required this.mainDescription,
    required this.detailing,
    required this.isActive,
  });
}
