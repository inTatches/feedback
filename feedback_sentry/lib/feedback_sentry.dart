import 'package:feedback/feedback.dart';
import 'package:flutter/foundation.dart';
import 'package:sentry/sentry.dart';

export 'package:feedback/feedback.dart';

/// Extension on [FeedbackController] in order to make
/// it easier to call [showAndUploadToSentry].
extension SentryFeedbackX on FeedbackController {
  /// This method opens the feedback ui and the users feedback
  /// is uploaded to Sentry after the user submitted his feedback.
  /// [name] and [email] are optional. They are shown in the Sentry.io ui.s
  void showAndUploadToSentry({
    Hub? hub,
    String? name,
    String? email,
  }) {
    show(
      sendToSentry(
        hub: hub,
        name: name,
        email: email,
      ),
    );
  }
}

@visibleForTesting
OnFeedbackCallback sendToSentry({
  Hub? hub,
  String? name,
  String? email,
}) {
  final realHub = hub ?? HubAdapter();

  return (UserFeedback feedback) async {
    await realHub.captureFeedback(
      SentryFeedback(
        contactEmail: email,
        name: name,
        message: feedback.text,
        unknown: feedback.extra,
      ),
      hint: Hint.withScreenshot(
        SentryAttachment.fromUint8List(
          feedback.screenshot,
          'screenshot.png',
          contentType: 'image/png',
        ),
      ),
    );
  };
}
