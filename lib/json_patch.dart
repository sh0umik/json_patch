library json_patch;

import 'dart:convert';
import 'package:json_patch/model/json_patch.dart';

class JsonPatch {
  final Set<String> ignoreFields;
  JsonPatch({this.ignoreFields});

  List<JsonPatchOperation> buildPatchesFromMap(Map oldJson, Map newJson) {
    return diff(ignoreFields,oldJson, newJson, "");
  }

  List<JsonPatchOperation> buildPatchesFromString(String oldJson, String newJson) {
    var oldEncodedJson = jsonDecode(oldJson);
    var newEncodedJson = jsonDecode(newJson);
    return diff(ignoreFields, oldEncodedJson, newEncodedJson, "");
  }
}

List<JsonPatchOperation> diff(Set<String> ignoreFields,
    Map<String, dynamic> a, Map<String, dynamic> b, String path) {
  List<JsonPatchOperation> patches = <JsonPatchOperation>[];

  b.forEach((key, bv) {

    if(!ignoreFields.contains(key)) {
      var p = makePath(path, key);
      var av = a[key];
      if (av == null && bv != null) {
        patches.add(NewPatch("add", p, bv));
      }

      //if types have changed then replace completely
      if (av.runtimeType != bv.runtimeType && av != null) {
        patches.add(NewPatch("replace", p, bv));
      }

      patches.addAll(handleValues(ignoreFields, av, bv, p));
    }
  });

  a.forEach((key, val) {

    if(!ignoreFields.contains(key)) {
      var found = b[key];
      if (found == null && val != null) {
        var p = makePath(path, key);
        patches.add(NewPatch("remove", p, null));
      }
    }
  });

  return patches;
}

List<JsonPatchOperation> handleValues(Set<String> ignoreFields, dynamic av, dynamic bv, String p) {
  List<JsonPatchOperation> patches = <JsonPatchOperation>[];

  // Handle value if same type
  if (av.runtimeType == bv.runtimeType && av != null && bv != null) {
    if (av is Map) {
      patches.addAll(diff(ignoreFields, av, bv, p));
    } else if (av is String || av is double || av is int || av is bool) {
      if (!matchValue(av, bv)) {
        patches.add(JsonPatchOperation(op: "replace", path: p, value: bv));
      }
    } else if (av is List) {
      var bt = bv;
      var at = av;
      if (bt == null) {
        // array replaced by non-array
        patches.add(NewPatch("replace", p, bv));
      } else if (at.length != bt.length) {
        // arrays are not the same length
        patches.addAll(compareArray(at, bt, p));
      } else {
        for (var i = 0; i < bt.length; i++) {
          patches = handleValues(ignoreFields, at[i], bt[i], makePath(p, i));
        }
      }
    } else if (av == null) {
      if (av == null) {
        // Both Fine
      } else {
        patches.add(NewPatch("add", p, bv));
      }
    } else {
      print("Unknown type ");
      print(av.runtimeType);
    }
  }
  return patches;
}

List<JsonPatchOperation> compareArray(
    List<dynamic> av, List<dynamic> bv, String p) {
  List<JsonPatchOperation> retval = <JsonPatchOperation>[];

  for (var i = 0; i < av.length; i++) {
    bool found = false;
    for (var j = 0; j < bv.length; j++) {
      if (av[i] == bv[j]) {
        found = true;
        break;
      }
    }
    if (!found) {
      retval.add(NewPatch("remove", makePath(p, i), null));
    }
  }

  for (var i = 0; i < bv.length; i++) {
    bool found = false;
    for (var j = 0; j < av.length; j++) {
      if (av[j] == bv[i]) {
        found = true;
        break;
      }
    }
    if (!found) {
      retval.add(NewPatch("add", makePath(p, i), bv[i]));
    }
  }

  return retval;
}

bool matchValue(dynamic av, dynamic bv) {
  if (av.runtimeType != bv.runtimeType) {
    return false;
  }
  switch (av.runtimeType) {
    case String:
      var bt = bv.toString();
      if (bt == av) {
        return true;
      }
      break;
    case double:
      var bt = bv;
      if (bt == av) {
        return true;
      }
      break;
    case int:
      var bt = bv;
      if (bt == av) {
        return true;
      }
      break;
    case bool:
      var bt = bv.cast<bool>();
      if (bt == av) {
        return true;
      }
      break;
    case Map:
      var bt = bv.cast<Map<String, dynamic>>();
      var at = av.cast<Map<String, dynamic>>();
      at.forEach((key, _) {
        if (!matchValue(key, bt[key])) {
          return false;
        }
      });
      bt.forEach((key, _) {
        if (!matchValue(key, bt[key])) {
          return false;
        }
      });
      return true;
      break;
    case List:
      // todo
      return true;
      break;
  }

  return false;
}

JsonPatchOperation NewPatch(String operation, String path, dynamic value) {
  return JsonPatchOperation(op: operation, path: path, value: value);
}

String makePath(String path, dynamic newPart) {
  var key = newPart.toString();
  if (path == "") {
    return "/" + key;
  }
  if (path.endsWith("/")) {
    return path + key;
  }
  return path + "/" + key;
}
