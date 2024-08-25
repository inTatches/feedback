import 'package:feedback/feedback.dart';
import 'package:flutter/foundation.dart';
import 'package:sentry/sentry.dart';

export 'package:feedback/feedback.dart';

/// Extension on [FeedbackController] in order to make
/// it easier to call [showAndUploadToSentry].
extension SentryFeedback on FeedbackController {
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

  /// This method opens the feedback ui and the users feedback
  /// is uploaded to Sentry after the user submitted his feedback.
  /// [name] and [email] are optional. They are shown in the Sentry.io ui.s
  void showAndUploadToSentryWithException({
    Hub? hub,
    String? name,
    String? email,
    Object? exception,
    StackTrace? stackTrace,
  }) {
    show(
      sendToSentryWithException(
        hub: hub,
        name: name,
        email: email,
        exception: exception,
        stackTrace: stackTrace,
      ),
    );
  }
}

/// See [SentryFeedback.showAndUploadToSentry].
/// This is just [visibleForTesting].
@visibleForTesting
OnFeedbackCallback sendToSentry({
  Hub? hub,
  String? name,
  String? email,
}) {
  final realHub = hub ?? HubAdapter();

  return (UserFeedback feedback) async {
    final id = await realHub.captureMessage(
      feedback.text,
      withScope: (scope) {
        scope.addAttachment(
          SentryAttachment.fromUint8List(
            feedback.screenshot,
            'screenshot.png',
            contentType: 'image/png',
          ),
        );
      },
    );
    await realHub.captureUserFeedback(
      SentryUserFeedback(
        eventId: id,
        email: email,
        name: name,
        comments: '${feedback.text}\n${feedback.extra}',
      ),
    );
  };
}

/// See [SentryFeedback.showAndUploadToSentryWithException].
/// This is just [visibleForTesting].
@visibleForTesting
OnFeedbackCallback sendToSentryWithException({
  Hub? hub,
  String? name,
  String? email,
  Object? exception,
  StackTrace? stackTrace,
}) {
  final realHub = hub ?? HubAdapter();

  return (UserFeedback feedback) async {
    final id = await realHub.captureException(
      exception,
      stackTrace: stackTrace,
      withScope: (scope) {
        scope.addAttachment(
          SentryAttachment.fromUint8List(
            feedback.screenshot,
            'screenshot.png',
            contentType: 'image/png',
          ),
        );
      },
    );
    await realHub.captureUserFeedback(
      SentryUserFeedback(
        eventId: id,
        email: email,
        name: name,
        comments: '${feedback.text}\n${feedback.extra}',
      ),
    );
  };
}
