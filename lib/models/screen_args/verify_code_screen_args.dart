class VerifyCodeScreenArgs {
  final String phoneNumber;
  final String verificationId;
  final int? resendToken;

  const VerifyCodeScreenArgs(
      {required this.verificationId, required this.resendToken, required this.phoneNumber});
}
