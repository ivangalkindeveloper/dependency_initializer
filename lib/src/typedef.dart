import 'package:dependency_initializer/dependency_initializer.dart';

/// Type DIProcess - abbreviation for [DependencyInitializationProcess].
typedef DIProcess<Result> = DependencyInitializationProcess<Result>;

/// Type DIStep - abbreviation for [DependencyInitializationStep].
typedef DIStep<Process> = DependencyInitializationStep<Process>;

/// Type DIResult - abbreviation for [DependencyInitializationResult].
typedef DIResult<Process, Result>
    = DependencyInitializationResult<Process, Result>;
