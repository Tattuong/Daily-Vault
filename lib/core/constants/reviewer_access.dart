/// Google Play review credentials (App content > App access).
/// Reviewers enter this 4-digit PIN on Create PIN or the lock screen.
class ReviewerAccess {
  static const pin = '2580';

  static bool matches(String value) => value == pin;
}
