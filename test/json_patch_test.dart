import 'package:flutter_test/flutter_test.dart';

import 'package:json_patch/json_patch.dart';

void main() {
  test('simple json value chagnes test', () {
    final calculator = JsonPatch();
    expect(calculator.buildPatchesFromMap({"foo": "baz"}, {"foo": "baz1"}),
        [JsonPatchOperation(op: "replace", path: "/foo", value: "baz1")]);
    //expect(calculator.addOne(-7), -6);
    //expect(calculator.addOne(0), 1);
    //expect(() => calculator.addOne(null), throwsNoSuchMethodError);
  });
}
