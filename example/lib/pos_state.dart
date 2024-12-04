
class PosState {
  final bool isConnected;
  final bool isLoading;
  final String message;

  const PosState._({
    required this.isConnected,
    required this.isLoading,
    required this.message,
  });

  // Copy function to create a new state with overridden values
  PosState copyWith({
    bool? isConnected,
    bool? isLoading,
    String? message,
  }) {
    return PosState._(
      isConnected: isConnected ?? this.isConnected,
      isLoading: isLoading ?? this.isLoading,
      message: message ?? this.message,
    );
  }

  factory PosState.initial() =>
      const PosState._(isConnected: false, isLoading: false, message: "");
}
