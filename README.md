## Contact Input Tag

Package helps you to make email or phone number contact tags like Google Gmail.

You can custom your model phone number to be compatible with your language, the default is the Vietnamese phone number format.

## Features

![ezgif-1-6498164a72](https://user-images.githubusercontent.com/28478203/190557770-ca6003e0-746b-4864-9304-ca2188296154.gif)

## Usage

To use package. Add to your dependencies in pubspec.yaml file

```dart
contact_input_tag:
    git: https://github.com/Ceschref/contact_input_tag
```
Phone Number input tag example

```dart
 ContactInputTag(
                label: 'Your Phone Number',
                hintText: 'Input phone',
                updateResult: (items) {},
                typeTag: TypeTag.phoneNumber,
              ),
```

Email input tag example

```dart
 ContactInputTag(
                label: 'Your Email',
                hintText: 'Input mail',
                updateResult: (items) {},
                typeTag: TypeTag.email,
                listRecord: ['mail1@gmail.com'],
              ),
```
