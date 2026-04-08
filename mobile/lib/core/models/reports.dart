import 'package:equatable/equatable.dart';

class ReportDownloadLink extends Equatable {
  const ReportDownloadLink({required this.url, required this.expiresAt});

  final String url;
  final String expiresAt;

  factory ReportDownloadLink.fromJson(Map<String, dynamic> j) =>
      ReportDownloadLink(
        url: j['url'] as String? ?? '',
        expiresAt: j['expires_at'] as String? ?? '',
      );

  @override
  List<Object?> get props => [url];
}
