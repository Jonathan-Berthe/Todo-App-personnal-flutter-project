class HttpException implements Exception{
  final String mess;
  HttpException(this.mess);

  @override
  String toString() {
    return mess;
  }
}