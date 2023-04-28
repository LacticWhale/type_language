## Features

- Parse type language files.

## Usage

```dart
const definition = TypeLanguageDefinition();
final parser = definition.build<TypeLanguageProgram>();

final result = parser.parse('''user id:int name:string = User;''');
print(result.value);
```

## Additional information

- Incredibly broken.
