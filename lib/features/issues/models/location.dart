// lib/features/issues/models/location.dart

class IssueLocation {
  final String areaName;
  final String wardNumber;
  final double latMock;
  final double lngMock;

  const IssueLocation({
    required this.areaName,
    required this.wardNumber,
    this.latMock = 0.0,
    this.lngMock = 0.0,
  });

  String get displayName => '$areaName, Ward $wardNumber';

  IssueLocation copyWith({
    String? areaName,
    String? wardNumber,
    double? latMock,
    double? lngMock,
  }) {
    return IssueLocation(
      areaName: areaName ?? this.areaName,
      wardNumber: wardNumber ?? this.wardNumber,
      latMock: latMock ?? this.latMock,
      lngMock: lngMock ?? this.lngMock,
    );
  }
}

class MockLocations {
  static const List<IssueLocation> all = [
    IssueLocation(areaName: 'Koramangala', wardNumber: '12', latMock: 12.9352, lngMock: 77.6245),
    IssueLocation(areaName: 'Indiranagar', wardNumber: '7', latMock: 12.9784, lngMock: 77.6408),
    IssueLocation(areaName: 'HSR Layout', wardNumber: '18', latMock: 12.9116, lngMock: 77.6389),
    IssueLocation(areaName: 'Jayanagar', wardNumber: '5', latMock: 12.9251, lngMock: 77.5938),
    IssueLocation(areaName: 'Whitefield', wardNumber: '24', latMock: 12.9698, lngMock: 77.7500),
    IssueLocation(areaName: 'BTM Layout', wardNumber: '9', latMock: 12.9166, lngMock: 77.6101),
    IssueLocation(areaName: 'Marathahalli', wardNumber: '21', latMock: 12.9591, lngMock: 77.6974),
    IssueLocation(areaName: 'JP Nagar', wardNumber: '14', latMock: 12.9102, lngMock: 77.5921),
    IssueLocation(areaName: 'Rajajinagar', wardNumber: '3', latMock: 12.9926, lngMock: 77.5518),
    IssueLocation(areaName: 'Malleshwaram', wardNumber: '2', latMock: 13.0034, lngMock: 77.5650),
  ];
}
