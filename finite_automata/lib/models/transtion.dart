class transitionModel {
  final String fromState;
  final String toState;
  final String symbol;

  transitionModel({
    required this.fromState,
    required this.toState,
    required this.symbol,
  });

  Map<String, dynamic> toJson() => {
        'fromState': fromState,
        'toState': toState,
        'symbol': symbol,
      };

  factory transitionModel.fromJson(Map<String, dynamic> json) => transitionModel(
        fromState: json['fromState'],
        toState: json['toState'],
        symbol: json['symbol'],
      );
}