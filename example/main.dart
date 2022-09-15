import 'package:contact_input_tag/contact_input_tag.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Contact Input Tag'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (currentFocus.isFirstFocus || currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ContactInputTag(
                label: 'Your Phone Number',
                hintText: 'Input phone',
                updateResult: (items) {},
                typeTag: TypeTag.phoneNumber,
                // ignore: prefer_const_literals_to_create_immutables
                listRecord: [
                  '0977584232',
                ],
              ),
              const SizedBox(
                height: 24,
              ),
              ContactInputTag(
                label: 'Your Email',
                hintText: 'Input mail',
                updateResult: (items) {},
                typeTag: TypeTag.email,
                // ignore: prefer_const_literals_to_create_immutables
                listRecord: ['mail1@gmail.com'],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
