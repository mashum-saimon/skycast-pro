import 'package:geolocator/geolocator.dart';
import '../core/utils/failure.dart';
import 'package:dartz/dartz.dart';

class LocationService {
  Future<Either<Failure, Position>> getCurrentPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const Left(
          LocationFailure('Location services are disabled on this device.'),
        );
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return const Left(
            LocationFailure('Location permission was denied.'),
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return const Left(
          LocationFailure(
            'Location permission is permanently denied. Enable it in settings.',
          ),
        );
      }

      final position = await Geolocator.getCurrentPosition();
      return Right(position);
    } catch (_) {
      return const Left(LocationFailure());
    }
  }
}
