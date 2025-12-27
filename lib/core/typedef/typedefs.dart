import 'package:dartz/dartz.dart';

import '../errors/failure.dart';

typedef FutureEither<T> = Future<Either<Failure, T>>;
