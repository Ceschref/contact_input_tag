library contact_input_tag;

import 'dart:async';

import 'package:contact_input_tag/color_extension.dart';
import 'package:contact_input_tag/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum TypeTag {
  email,
  phoneNumber,
}

/// Extension for Type Tag parameter
extension TypeTagExts on TypeTag {
  bool get isTypeTagEmail {
    return this == TypeTag.email;
  }
}

class ContactInputTag extends StatefulWidget {
  const ContactInputTag({
    Key? key,
    this.hintText,
    this.label,
    this.focusNode,
    required this.updateResult,
    this.listRecord,
    this.textEditingController,
    this.typeTag = TypeTag.email,
    this.isRequired = false,
    this.listTextInputFormatter,
    this.phoneNumberPattern = r'(09|03|07|08|05)+([0-9]{8})\b',
  }) : super(key: key);

  /// Hint text for TextField
  final String? label;

  /// Hint text for TextField
  final String? hintText;

  /// Optional textEditingController for TextField
  final TextEditingController? textEditingController;

  /// Type of Contact Tag (Email or Phone Number)
  final TypeTag typeTag;

  /// Optional FocusNode for TextField
  final FocusNode? focusNode;

  /// One parameter to check is display (*). Field marking is required. Default is false
  final bool isRequired;

  /// List record data init
  final List<String>? listRecord;

  /// Function callback when you have actions (unfocus, space, delete)
  final Function(List<dynamic>) updateResult;

  /// To make sure that the data you enter is correct
  final List<TextInputFormatter>? listTextInputFormatter;

  /// Model your phone number to be compatible with your language, the default is the Vietnamese phone number format
  final String phoneNumberPattern;

  @override
  ContactInputTagState createState() => ContactInputTagState();
}

class ContactInputTagState extends State<ContactInputTag> {
  late final TextEditingController textEditingController;
  late final FocusNode _focusNode;
  late final List<TextInputFormatter>? listTextInputFormatter;

  final StreamController<int> _streamController = StreamController.broadcast();

  List<Map<String, dynamic>> listRecord = [];
  String hintText = '';

  List<dynamic> get getResult {
    return listRecord
        .map((item) =>
            item[widget.typeTag.isTypeTagEmail ? 'email' : 'phoneNumber'])
        .toList();
  }

  String get getText {
    return textEditingController.text.replaceAll('\u200B', '');
  }

  @override
  void initState() {
    super.initState();
    textEditingController =
        widget.textEditingController ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    listTextInputFormatter = widget.listTextInputFormatter ??
        (widget.typeTag.isTypeTagEmail
            ? null
            : <TextInputFormatter>[
                FilteringTextInputFormatter.allow(
                  RegExp(r'[0-9 \u200B]+'),
                ),
              ]);
    textEditingController.addListener(() {
      if (listRecord.isEmpty && textEditingController.text == '\u200B\u200B') {
        textEditingController.clear();
      }
    });
    hintText = widget.hintText ?? 'Your tag';
    _initListRecord();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _updateResult();
      }
    });
  }

  void _updateResult() {
    widget.updateResult(listRecord
        .map((e) => e[widget.typeTag.isTypeTagEmail ? 'email' : 'phoneNumber'])
        .toList());
  }

  void _initListRecord() {
    widget.listRecord?.removeWhere((element) => element == '');
    if (widget.listRecord != null && widget.listRecord!.isNotEmpty) {
      for (var element in widget.listRecord!) {
        element = element.trim();
        if (widget.typeTag.isTypeTagEmail) {
          if (element.checkEmail) {
            listRecord.add({
              'email': element,
              'color': ExtendedColors.randomColor,
            });
          }
        } else if (element.checkPhoneNumber(widget.phoneNumberPattern)) {
          listRecord.add({
            'phoneNumber': element,
          });
        } else {
          continue;
        }
      }
      _resetTextBlank();
    } else {
      listRecord = [];
    }
  }

  void _clearAllText() {
    textEditingController.text =
        textEditingController.text.replaceAll('\u200B', '');
  }

  void _setTextWithBlank() {
    textEditingController
      ..text =
          '\u200B\u200B' + textEditingController.text.replaceAll('\u200B', '')
      ..selection = TextSelection.fromPosition(
        TextPosition(
          offset: textEditingController.text.length,
        ),
      );
  }

  void _resetTextBlank() {
    textEditingController
      ..text = '\u200B\u200B'
      ..selection = TextSelection.fromPosition(
        TextPosition(
          offset: textEditingController.text.length,
        ),
      );
  }

  void _listenOnChange() async {
    if (textEditingController.text.isNotEmpty) {
      final value = textEditingController.text.trim().replaceAll('\u200B', '');
      if (widget.typeTag.isTypeTagEmail && value.checkEmail) {
        if (!listRecord.any((element) => element['email'] == value)) {
          listRecord.add({
            'email': value,
            'color': ExtendedColors.randomColor,
          });
        }
      } else if (value.checkPhoneNumber(widget.phoneNumberPattern) &&
          !widget.typeTag.isTypeTagEmail) {
        if (!listRecord.any((element) => element['phoneNumber'] == value)) {
          listRecord.add({
            'phoneNumber': value,
          });
        }
      } else {
        _updateResult();
        return;
      }
      setState(() {});
      _resetTextBlank();
      _updateResult();
    } else {
      _clearAllText();
    }
  }

  void _deleteLast(int index) {
    listRecord.removeAt(index);
    if (listRecord.isEmpty) {
      hintText = widget.hintText ?? 'Your tag';
      _clearAllText();
    } else {
      _setTextWithBlank();
    }
    _updateResult();
    setState(() {});
  }

  void _onChange(String value) {
    if (value.endsWith(' ')) {
      _listenOnChange();
    } else if (value == '\u200B' && listRecord.isNotEmpty) {
      _streamController.add(listRecord.length - 1);
    } else if (value.isEmpty && listRecord.isNotEmpty) {
      _deleteLast(listRecord.length - 1);
    } else {
      _streamController.add(-1);
    }
  }

  Widget _buildItemTag(String value, Color? color, int index) {
    return StreamBuilder<int>(
      initialData: -1,
      stream: _streamController.stream,
      builder: (context, snapshot) {
        return Container(
          margin: const EdgeInsets.only(right: 5.0),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFD1D5DB), width: 1),
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            color: snapshot.data == index ? const Color(0xFFD1D5DB) : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.typeTag.isTypeTagEmail)
                Container(
                  alignment: Alignment.center,
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.fromLTRB(1, 1, 0, 1),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    color: color ?? ExtendedColors.randomColor,
                  ),
                  child: Text(
                    value.getLetterFirstName,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Text(value),
              ),
              GestureDetector(
                behavior: HitTestBehavior.deferToChild,
                onTap: () {
                  _deleteLast(index);
                },
                child: const Icon(
                  Icons.cancel_outlined,
                  size: 18,
                ),
              ),
              const SizedBox(
                width: 8.0,
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (widget.label != null)
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: widget.label,
                  style: const TextStyle(color: Color(0xFF323B4B)),
                ),
                if (widget.isRequired)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: Color(0xFFE81C35)),
                  ),
              ],
            ),
          ),
        if (widget.label != null)
          const SizedBox(
            height: 10,
          ),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 5,
          children: [
            ...listRecord
                .map(
                  (item) => _buildItemTag(
                    item[widget.typeTag.isTypeTagEmail
                        ? 'email'
                        : 'phoneNumber'],
                    item['color'],
                    listRecord.indexOf(item),
                  ),
                )
                .toList(),
            Container(
              height: 24,
              constraints: BoxConstraints(
                maxWidth: (MediaQuery.of(context).size.width - 32) / 2,
              ),
              child: TextField(
                controller: textEditingController,
                focusNode: _focusNode,
                autocorrect: false,
                keyboardType: widget.typeTag.isTypeTagEmail
                    ? TextInputType.emailAddress
                    : const TextInputType.numberWithOptions(signed: true),
                inputFormatters: listTextInputFormatter,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(0),
                  hintText: hintText,
                  hintStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color.fromARGB(255, 122, 124, 129),
                  ),
                  border: const OutlineInputBorder(borderSide: BorderSide.none),
                  focusedBorder:
                      const OutlineInputBorder(borderSide: BorderSide.none),
                  enabledBorder:
                      const OutlineInputBorder(borderSide: BorderSide.none),
                ),
                onChanged: _onChange,
                onSubmitted: (value) {
                  _listenOnChange();
                },
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        const Divider(height: 1, color: Color(0xFFD1D5DB)),
      ],
    );
  }
}
