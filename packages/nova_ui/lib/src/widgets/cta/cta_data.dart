final class CtaData {
  final String text;
  final double height;
  final double width;
  final void Function() onTapped;

  const CtaData({
    required this.text,
    this.height = 54,
    this.width = double.infinity,
    required this.onTapped,
  });
}
