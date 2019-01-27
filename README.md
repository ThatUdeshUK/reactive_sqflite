# reactive_sqflite

Reactive wrapper around sqflite database. Supports both iOS and Android.

* Support insert, delete, update and quering
* Return queries as `rxdart` Observables
* Get updates for queries on insertions, deletions and updates

Transaction and batch execution is not yet supported.

## Getting Started

In your flutter project add the dependency:

```yml
dependencies:
  ...
  reactive_sqflite: any
```

For help getting started with Flutter, view the online
[documentation](https://flutter.io/).

## Usage

Import `reactive_sqflite.dart`

```dart
import 'package:reactive_sqflite/reactive_sqflite.dart';
```

Read sqflite and rxdart documentation for further reference,

* [sqflite](https://pub.dartlang.org/packages/sqflite)
* [rxdart](https://pub.dartlang.org/packages/rxdart)

## Example

See the `example` directory for a sample.