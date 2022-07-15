part of '../state_provider.dart';

/// {@macro riverpod.providerrefbase}
/// - [controller], the [StateController] currently exposed by this provider.
abstract class AutoDisposeStateProviderRef<State>
    implements
        AutoDisposeRef<StateController<State>>,
        StateProviderRef<State> {}

/// {@macro riverpod.stateprovider}
@sealed
class AutoDisposeStateProvider<State> extends AutoDisposeProviderBase<State>
    with
        StateProviderOverrideMixin<State>,
        OverrideWithProviderMixin<StateController<State>,
            AutoDisposeStateProvider<State>> {
  /// {@macro riverpod.stateprovider}
  AutoDisposeStateProvider(
    Create<State, AutoDisposeStateProviderRef<State>> create, {
    String? name,
    List<ProviderOrFamily>? dependencies,
    Family? from,
    Object? argument,
    Duration? cacheTime,
    Duration? disposeDelay,
  })  : notifier = _AutoDisposeNotifierProvider(
          create,
          name: modifierName(name, 'notifier'),
          dependencies: dependencies,
          from: from,
          argument: argument,
          cacheTime: cacheTime,
          disposeDelay: disposeDelay,
        ),
        super(
          name: name,
          from: from,
          argument: argument,
          cacheTime: cacheTime,
          disposeDelay: disposeDelay,
        );

  /// {@macro riverpod.family}
  static const family = AutoDisposeStateProviderFamilyBuilder();

  /// {@macro riverpod.stateprovider.notifier}
  @override
  final AutoDisposeProviderBase<StateController<State>> notifier;

  @override
  late final AutoDisposeProviderBase<StateController<State>> state =
      _AutoDisposeStateProviderState(
    this,
    dependencies: [notifier],
    from: from,
    argument: argument,
    cacheTime: cacheTime,
    disposeDelay: disposeDelay,
    name: modifierName(name, 'state'),
  );

  @override
  AutoDisposeStateProviderElement<State> createElement() {
    return AutoDisposeStateProviderElement(this);
  }
}

/// The [ProviderElementBase] for [StateProvider]
class AutoDisposeStateProviderElement<State>
    extends AutoDisposeProviderElementBase<State> {
  /// The [ProviderElementBase] for [StateProvider]
  AutoDisposeStateProviderElement(this.provider);

  @override
  final AutoDisposeStateProvider<State> provider;

  @override
  State create() {
    final notifier = watch(provider.notifier);

    final removeListener = notifier.addListener(setState);
    onDispose(removeListener);

    return notifier.state;
  }

  @override
  bool updateShouldNotify(State previousState, State newState) {
    return true;
  }
}

class _AutoDisposeNotifierProvider<State>
    extends AutoDisposeProviderBase<StateController<State>> {
  _AutoDisposeNotifierProvider(
    this._create, {
    required String? name,
    required this.dependencies,
    required Family? from,
    required Object? argument,
    required Duration? cacheTime,
    required Duration? disposeDelay,
  }) : super(
          name: name,
          from: from,
          argument: argument,
          cacheTime: cacheTime,
          disposeDelay: disposeDelay,
        );

  final Create<State, AutoDisposeStateProviderRef<State>> _create;

  @override
  final List<ProviderOrFamily>? dependencies;

  @override
  _AutoDisposeNotifierStateProviderElement<State> createElement() {
    return _AutoDisposeNotifierStateProviderElement(this);
  }
}

class _AutoDisposeNotifierStateProviderElement<State>
    extends AutoDisposeProviderElementBase<StateController<State>>
    implements AutoDisposeStateProviderRef<State> {
  _AutoDisposeNotifierStateProviderElement(this.provider);

  @override
  final _AutoDisposeNotifierProvider<State> provider;

  @override
  StateController<State> get controller => requireState;

  @override
  StateController<State> create() {
    final initialState = provider._create(this);
    final notifier = StateController(initialState);
    onDispose(notifier.dispose);
    return notifier;
  }

  @override
  bool updateShouldNotify(
    StateController<State> previousState,
    StateController<State> newState,
  ) {
    return true;
  }
}

class _AutoDisposeStateProviderState<State>
    extends AutoDisposeProviderBase<StateController<State>> {
  _AutoDisposeStateProviderState(
    this._origin, {
    required this.dependencies,
    required super.from,
    required super.argument,
    required super.name,
    required super.cacheTime,
    required super.disposeDelay,
  });

  final AutoDisposeStateProvider<State> _origin;

  @override
  final List<ProviderOrFamily>? dependencies;

  @override
  _AutoDisposeStateProviderStateElement<State> createElement() {
    return _AutoDisposeStateProviderStateElement(this);
  }
}

class _AutoDisposeStateProviderStateElement<State>
    extends AutoDisposeProviderElementBase<StateController<State>> {
  _AutoDisposeStateProviderStateElement(this.provider);

  @override
  final _AutoDisposeStateProviderState<State> provider;

  @override
  StateController<State> create() {
    return _listenStateProvider(
      this,
      watch(provider._origin.notifier),
    );
  }

  @override
  bool updateShouldNotify(
    StateController<State> previousState,
    StateController<State> newState,
  ) {
    return true;
  }
}

/// {@macro riverpod.stateprovider.family}
@sealed
class AutoDisposeStateProviderFamily<State, Arg>
    extends Family<State, Arg, AutoDisposeStateProvider<State>> {
  /// {@macro riverpod.stateprovider.family}
  AutoDisposeStateProviderFamily(
    this._create, {
    String? name,
    List<ProviderOrFamily>? dependencies,
    Duration? cacheTime,
    Duration? disposeDelay,
  }) : super(
          name: name,
          dependencies: dependencies,
          cacheTime: cacheTime,
          disposeDelay: disposeDelay,
        );

  final FamilyCreate<State, AutoDisposeStateProviderRef<State>, Arg> _create;

  @override
  AutoDisposeStateProvider<State> create(Arg argument) {
    return AutoDisposeStateProvider<State>(
      (ref) => _create(ref, argument),
      name: name,
      from: this,
      argument: argument,
      cacheTime: cacheTime,
      disposeDelay: disposeDelay,
    );
  }

  @override
  void setupOverride(Arg argument, SetupOverride setup) {
    final provider = call(argument);
    setup(origin: provider.notifier, override: provider.notifier);
  }

  /// {@macro riverpod.overridewithprovider}
  Override overrideWithProvider(
    AutoDisposeStateProvider<State> Function(Arg argument) override,
  ) {
    return FamilyOverride<Arg>(
      this,
      (arg, setup) {
        final provider = call(arg);
        final newProvider = override(arg);
        setup(origin: provider.notifier, override: newProvider.notifier);
      },
    );
  }
}
