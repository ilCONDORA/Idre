import 'package:idre/theme/idre_theme.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  runApp(const IdreApp());
}

class IdreApp extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: IdreThemes.light,
      darkTheme: IdreThemes.dark,
      home: const Scaffold(body: Center(child: Text('Hello World!'))),
    );
  }
}
