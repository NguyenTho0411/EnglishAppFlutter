import 'package:dartz/dartz.dart';
import '../../../../core/errors/exception.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/typedef/typedefs.dart';
import '../../domain/entities/word_progress_entity.dart';
import '../../domain/repositories/word_progress_repository.dart';
import '../data_sources/word_progress_remote_data_source.dart';
import '../models/word_progress_model.dart';

class WordProgressRepositoryImpl implements WordProgressRepository {
  final WordProgressRemoteDataSource remoteDataSource;

  WordProgressRepositoryImpl(this.remoteDataSource);

  @override
  FutureEither<void> saveProgress({
    required String uid,
    required WordProgressEntity progress,
  }) async {
    try {
      final model = WordProgressModel.fromEntity(progress);
      await remoteDataSource.saveProgress(uid: uid, progress: model);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  FutureEither<WordProgressEntity?> getProgress({
    required String uid,
    required String wordId,
  }) async {
    try {
      final model = await remoteDataSource.getProgress(uid: uid, wordId: wordId);
      return Right(model);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  FutureEither<List<WordProgressEntity>> getAllProgress(String uid) async {
    try {
      final models = await remoteDataSource.getAllProgress(uid);
      return Right(models);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Stream<List<WordProgressEntity>> watchAllProgress(String uid) {
    return remoteDataSource.watchAllProgress(uid);
  }

  @override
  FutureEither<void> deleteProgress({
    required String uid,
    required String wordId,
  }) async {
    try {
      await remoteDataSource.deleteProgress(uid: uid, wordId: wordId);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  FutureEither<void> deleteAllProgress(String uid) async {
    try {
      await remoteDataSource.deleteAllProgress(uid);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
