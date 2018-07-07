import 'package:serializer_generator/serializer_generator.dart' as serializer;

void main() async {
  await serializer.build("redstone_database_mondo", ["example/server_example.dart"]);
}
