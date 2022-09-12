class ErrorModel {
  final String? error; // error message
  final dynamic data; // can be string, int, list, map, etc
  ErrorModel({
    required this.error,
    required this.data,
  });
}
