library contact_input_tag;

import 'dart:async';

import 'package:contact_input_tag/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './string_extension.dart';

enum TypeTag {
  email,
  phoneNumber,
}

extension TypeTagExts on TypeTag {
  bool get isTypeTagEmail {
    return this == TypeTag.email;
  }
}

class ContactInputTag extends StatefulWidget {
  const ContactInputTag({
    Key? key,
    required this.hintText,
    required this.label,
    required this.focusNode,
    required this.updateResult,
    this.listRecord,
    this.textEditingController,
    this.typeTag = TypeTag.email,
    this.required = false,
  }) : super(key: key);

  final String label;
  final String hintText;
  final TextEditingController? textEditingController;
  final TypeTag typeTag;
  final FocusNode focusNode;
  final bool required;
  final List<dynamic>? listRecord;
  final Function(List<dynamic>) updateResult;

  @override
  ContactInputTagState createState() => ContactInputTagState();
}

class ContactInputTagState extends State<ContactInputTag> {
  late final TextEditingController textEditingController;
  late final FocusNode _focusNode;

  final StreamController<int> _streamController = StreamController.broadcast();

  List<Map<String, dynamic>> listRecord = [];
  String hintText = '';
  bool firstTime = true;

  @override
  void initState() {
    super.initState();
    textEditingController = widget.textEditingController ?? TextEditingController();
    textEditingController.addListener(() {
      if (listRecord.isEmpty && textEditingController.text == '\u200B\u200B') {
        textEditingController.clear();
      }
    });
    hintText = widget.hintText;
    initListRecord();
    _focusNode = widget.focusNode;
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        listenOnChange(forceNoFocus: true);
        widget.updateResult(listRecord);
      }
    });
  }

  void initListRecord() {
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
        } else if (!widget.typeTag.isTypeTagEmail) {
          if (element.checkPhoneNumber) {
            listRecord.add({
              'phoneNumber': element,
            });
          }
        } else {
          listRecord = [];
          return;
        }
      }
      // hintText = '';
      textEditingController
        ..text = '\u200B\u200B'
        ..selection = TextSelection.fromPosition(
          TextPosition(
            offset: textEditingController.text.length,
          ),
        );
    } else {
      listRecord = [];
    }
  }

  void listenOnChange({bool forceNoFocus = false}) async {
    if (textEditingController.text.isNotEmpty) {
      final value = textEditingController.text.trim().replaceAll('\u200B', '');
      if (widget.typeTag.isTypeTagEmail && value.checkEmail) {
        if (!listRecord.any((element) => element['email'] == value)) {
          listRecord.add({
            'email': value,
            'color': ExtendedColors.randomColor,
          });
        }
      } else if (value.checkPhoneNumber && !widget.typeTag.isTypeTagEmail) {
        if (!listRecord.any((element) => element['phoneNumber'] == value)) {
          listRecord.add({
            'phoneNumber': value,
          });
        }
      } else {
        return;
      }
      setState(() {});
      if (!forceNoFocus) {
        _focusNode.requestFocus();
      }
      // hintText = '';
      textEditingController
        ..text = '\u200B\u200B'
        ..selection = TextSelection.fromPosition(
          TextPosition(
            offset: textEditingController.text.length,
          ),
        );
    } else {
      clearAllText();
    }
  }

  void clearAllText() {
    textEditingController.text.replaceAll('\u200B', '');
    setState(() {});
  }

  void onCheckDelete() {
    _streamController.add(listRecord.length - 1);
  }

  void _onChange(String value) {
    if (value.endsWith(' ')) {
      listenOnChange();
    } else if (value == '\u200B' && listRecord.isNotEmpty) {
      onCheckDelete();
    } else if (value.isEmpty && listRecord.isNotEmpty) {
      listRecord.removeLast();
      if (listRecord.isEmpty) {
        hintText = widget.hintText;
      } else {
        textEditingController
          ..text = '\u200B\u200B'
          ..selection = TextSelection.fromPosition(
            TextPosition(
              offset: textEditingController.text.length,
            ),
          );
      }
      setState(() {});
    }
  }

  List<dynamic> get getResult {
    return listRecord.map((item) => item[widget.typeTag.isTypeTagEmail ? 'email' : 'phoneNumber']).toList();
  }

  String get getText {
    return textEditingController.text.replaceAll('\u200B', '');
  }

  Widget _buildItemEmail(String email, Color? color, int index) {
    return StreamBuilder<int>(
      initialData: -1,
      stream: _streamController.stream,
      builder: (context, snapshot) {
        return Container(
          height: 22,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          margin: const EdgeInsets.only(right: 5.0),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFD1D5DB), width: 1),
            borderRadius: const BorderRadius.all(Radius.circular(6)),
            color: snapshot.data == index ? const Color(0xFFD1D5DB) : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.typeTag.isTypeTagEmail)
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      alignment: Alignment.topCenter,
                      width: 16.0,
                      height: 16.0,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(6)),
                        color: color,
                      ),
                    ),
                    Text(
                      email.getLetterFirstName,
                      style: const TextStyle(fontSize: 9.7, height: 16 / 9.7, color: Colors.white),
                    ),
                  ],
                ),
              if (widget.typeTag.isTypeTagEmail)
                const SizedBox(
                  width: 5.0,
                ),
              Text(email),
              const SizedBox(
                width: 5.0,
              ),
              GestureDetector(
                behavior: HitTestBehavior.deferToChild,
                onTap: () {
                  listRecord.removeAt(index);
                  if (!_focusNode.hasFocus) {
                    listenOnChange(forceNoFocus: true);
                    widget.updateResult(listRecord);
                  }
                  setState(() {});
                },
                child: const Icon(
                  Icons.cancel_outlined,
                  size: 18,
                ),
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
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: widget.label,
                style: const TextStyle(fontSize: 14, height: 16 / 14, color: Color(0xFF323B4B)),
              ),
              if (widget.required)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(fontSize: 14, height: 16 / 14, color: Color(0xFFE81C35)),
                ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 5,
          children: [
            ...listRecord
                .map(
                  (item) => _buildItemEmail(item[widget.typeTag.isTypeTagEmail ? 'email' : 'phoneNumber'],
                      item['color'], listRecord.indexOf(item)),
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
                keyboardType: TextInputType.emailAddress,
                inputFormatters: widget.typeTag.isTypeTagEmail
                    ? null
                    : <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp('[0-9 \u200B]+')),
                      ],
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(0),
                  hintText: hintText,
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 16 / 14,
                    color: Color(0xFF323B4B),
                  ),
                  border: const OutlineInputBorder(borderSide: BorderSide.none),
                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide.none),
                  enabledBorder: const OutlineInputBorder(borderSide: BorderSide.none),
                ),
                onChanged: _onChange,
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
