import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class EmailService {
  static Future<void> sendGatepassEmail({
    required String guardianEmail,
    required String studentName,
    required String gatepassId,
    required String token,
  }) async {
    final String email = dotenv.env['SMTP_EMAIL'] ?? '';
    final String password = dotenv.env['SMTP_PASSWORD'] ?? '';
    if (email.isEmpty || password.isEmpty) {
      print('❌ Missing SMTP credentials. Check your .env file.');
      return;
    }
    // Gmail setup
    final smtpServer = gmail(email, password);

    // Links (approve/reject)
    final approveLink =
        "https://HostelMate.com/gatepass?gatepassId=$gatepassId&action=approve&token=$token";
    final rejectLink =
        "https://HostelMate.com/gatepass?gatepassId=$gatepassId&action=reject&token=$token";

    final message =
        Message()
          ..from = Address('hhkotak.22@gmail.com', 'HostelMate')
          ..recipients.add(guardianEmail)
          ..subject = 'Gatepass Request for $studentName'
          ..text = '''
Hello,

$studentName has requested a gatepass.

Click below to approve or reject:
✅ Approve: $approveLink
❌ Reject: $rejectLink

Regards,
HostelMate
''';

    try {
      final sendReport = await send(message, smtpServer);
      print('✅ Email sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('❌ Email not sent. Problems: ${e.problems}');
    }
  }
}
