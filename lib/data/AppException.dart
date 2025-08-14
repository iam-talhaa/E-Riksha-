import 'package:flutter/material.dart';

class AppException implements Exception {
  String? _message;
  final _prefix;

  AppException(this._message, this._prefix);

  String toString() {
    return "$_message $_prefix";
  }
}

class FetchDataException extends AppException {
  FetchDataException(String? message)
    : super(message, 'Error During Communication');
}

class InvalidRequest extends AppException {
  InvalidRequest(String? message) : super(message, 'Invalid Request');
}

// Network / API

class BadRequestException extends AppException {
  BadRequestException(String? message) : super(message, 'Invalid Request');
}

class UnauthorizedException extends AppException {
  UnauthorizedException(String? message)
    : super(message, 'Unauthorized Access');
}

// Location / GPS
class LocationPermissionException extends AppException {
  LocationPermissionException(String? message)
    : super(message, 'Location Permission Denied');
}

class LocationServiceDisabledException extends AppException {
  LocationServiceDisabledException(String? message)
    : super(message, 'Location Services Disabled');
}

// Ride Logic
class NoDriverAvailableException extends AppException {
  NoDriverAvailableException(String? message)
    : super(message, 'No Drivers Available');
}

class RideCancelledException extends AppException {
  RideCancelledException(String? message) : super(message, 'Ride Cancelled');
}

// Payment
class PaymentFailedException extends AppException {
  PaymentFailedException(String? message) : super(message, 'Payment Failed');
}
