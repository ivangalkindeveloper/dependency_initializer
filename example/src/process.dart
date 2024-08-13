import 'package:initializer/src/initialization_process.dart';

import 'data/api.dart';
import 'bloc/bloc.dart';
import 'core/config.dart';
import 'data/dao.dart';
import 'data/http_client.dart';
import 'data/repository.dart';
import 'data/storage.dart';
import 'result.dart';

final class Process extends InitializationProcess<Result> {
  Config? config;
  HttpClient? client;
  Api? api;
  Dao? dao;
  Storage? storage;
  Repository? repository;
  Bloc? bloc;

  @override
  Result toResult() {
    assert(
      this.config != null,
    );
    assert(
      this.repository != null,
    );
    assert(
      this.bloc != null,
    );

    return Result(
      config: this.config!,
      repository: this.repository!,
      bloc: this.bloc!,
    );
  }
}
