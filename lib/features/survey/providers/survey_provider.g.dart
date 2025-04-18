// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'survey_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$surveyStateHash() => r'd9f42e8f9818394b291160c152bc97d062951edc';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$SurveyState extends BuildlessAutoDisposeAsyncNotifier<Survey> {
  late final String surveyId;

  FutureOr<Survey> build(
    String surveyId,
  );
}

/// See also [SurveyState].
@ProviderFor(SurveyState)
const surveyStateProvider = SurveyStateFamily();

/// See also [SurveyState].
class SurveyStateFamily extends Family<AsyncValue<Survey>> {
  /// See also [SurveyState].
  const SurveyStateFamily();

  /// See also [SurveyState].
  SurveyStateProvider call(
    String surveyId,
  ) {
    return SurveyStateProvider(
      surveyId,
    );
  }

  @override
  SurveyStateProvider getProviderOverride(
    covariant SurveyStateProvider provider,
  ) {
    return call(
      provider.surveyId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'surveyStateProvider';
}

/// See also [SurveyState].
class SurveyStateProvider
    extends AutoDisposeAsyncNotifierProviderImpl<SurveyState, Survey> {
  /// See also [SurveyState].
  SurveyStateProvider(
    String surveyId,
  ) : this._internal(
          () => SurveyState()..surveyId = surveyId,
          from: surveyStateProvider,
          name: r'surveyStateProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$surveyStateHash,
          dependencies: SurveyStateFamily._dependencies,
          allTransitiveDependencies:
              SurveyStateFamily._allTransitiveDependencies,
          surveyId: surveyId,
        );

  SurveyStateProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.surveyId,
  }) : super.internal();

  final String surveyId;

  @override
  FutureOr<Survey> runNotifierBuild(
    covariant SurveyState notifier,
  ) {
    return notifier.build(
      surveyId,
    );
  }

  @override
  Override overrideWith(SurveyState Function() create) {
    return ProviderOverride(
      origin: this,
      override: SurveyStateProvider._internal(
        () => create()..surveyId = surveyId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        surveyId: surveyId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<SurveyState, Survey> createElement() {
    return _SurveyStateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SurveyStateProvider && other.surveyId == surveyId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, surveyId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SurveyStateRef on AutoDisposeAsyncNotifierProviderRef<Survey> {
  /// The parameter `surveyId` of this provider.
  String get surveyId;
}

class _SurveyStateProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<SurveyState, Survey>
    with SurveyStateRef {
  _SurveyStateProviderElement(super.provider);

  @override
  String get surveyId => (origin as SurveyStateProvider).surveyId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
