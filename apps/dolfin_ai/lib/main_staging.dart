import 'main.dart' as runner;

void main() async {
  // We can add specific staging initialization here if needed
  // For now, we delegate to the main runner
  // Note: Ensure --dart-define=ENV=staging is passed in launch config
  runner.main();
}
