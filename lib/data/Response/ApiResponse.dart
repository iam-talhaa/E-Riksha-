import 'package:e_riksha/data/Response/status.dart';

class Apiresponse<T> {
  String? message;
  T? data;
  STATUS? status;

  Apiresponse({this.message, this.data, this.status});

  Apiresponse.Loading() : status = STATUS.Loading;
  Apiresponse.Error() : status = STATUS.Error;
  Apiresponse.Completed() : status = STATUS.Completed;

  String toString() {
    return 'Apiresponse{message: $message, data: $data, status: $status}';
  }
}
