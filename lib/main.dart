import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_sample/htmllpdf.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _createPDF,
              child: const Text('Create PDF'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createPDF() async {
    //Create a PDF document
    // PdfDocument document = PdfDocument();
    // //Add a page and draw text
    // PdfPage page = document.pages.add();

    // PdfFont regularFont = PdfStandardFont(PdfFontFamily.helvetica, 12);
    // PdfFont boldFont =
    //     PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold);
    // PdfFont italicFont = PdfStandardFont(PdfFontFamily.helvetica, 12,
    //     style: PdfFontStyle.italic);
    // PdfFont boldItalicFont = PdfStandardFont(PdfFontFamily.helvetica, 12,
    //     multiStyle: <PdfFontStyle>[PdfFontStyle.bold, PdfFontStyle.italic]);

    // //Load the text into PdfTextElement with standard font with regular style
    // PdfTextElement textElement = PdfTextElement(
    //     text: 'This is sample text with different font styles like',
    //     font: regularFont);
    // //Draw the text on page and maintain the position in PdfLayoutResult
    // PdfTextLayoutResult layoutResult = textElement.draw(
    //         page: page,
    //         bounds: Rect.fromLTWH(0, 50, page.getClientSize().width, 100))!
    //     as PdfTextLayoutResult;
    // //Load the text into
    // textElement = PdfTextElement(text: ' bold,', font: boldFont);
    // layoutResult = textElement.draw(
    //     page: page,
    //     bounds: Rect.fromLTWH(
    //         layoutResult.lastLineBounds!.right,
    //         50,
    //         page.getClientSize().width - layoutResult.lastLineBounds!.right,
    //         100))! as PdfTextLayoutResult;
    // textElement = PdfTextElement(text: ' italic,', font: italicFont);
    // layoutResult = textElement.draw(
    //     page: page,
    //     bounds: Rect.fromLTWH(
    //         layoutResult.lastLineBounds!.right,
    //         50,
    //         page.getClientSize().width - layoutResult.lastLineBounds!.right,
    //         100))! as PdfTextLayoutResult;
    // textElement =
    //     PdfTextElement(text: ' bold and italic.', font: boldItalicFont);
    // layoutResult = textElement.draw(
    //     page: page,
    //     bounds: Rect.fromLTWH(
    //         layoutResult.lastLineBounds!.right,
    //         50,
    //         page.getClientSize().width - layoutResult.lastLineBounds!.right,
    // 100))! as PdfTextLayoutResult;

    //Save the document
    List<int> bytes =
        await WidgetsHTMLDecoder().convert('''<h1>AppFlowyEditor</h1>
<h2> <strong>Welcome to</strong> <strong><em><a href="appflowy.io">AppFlowy Editor</a></em></strong></h2>
  <p>AppFlowy Editor is a <strong>highly customizable</strong> <em>rich-text editor</em></p>
<p><u>Here</u> is an example <del>your</del> you can give a try</p>
<br>
<span style="font-weight: bold;background-color: #cccccc;font-style: italic;">Span element</span>
<span style="font-weight: medium;text-decoration: underline;">Span element two</span>
</br>
<span style="font-weight: 900;text-decoration: line-through;">Span element three</span>
<a href="https://appflowy.io">This is an anchor tag!</a>

<h3>Features!</h3>''');
    //Dispose the document

    //Get external storage directory
    Directory directory = (await getApplicationSupportDirectory());
    //Get directory path
    String path = directory.path;
    //Create an empty file to write PDF data
    File file = File('$path/Output.pdf');
    //Write PDF data
    await file.writeAsBytes(bytes, flush: true);
    //Open the PDF document in mobile
    OpenFile.open('$path/Output.pdf');
  }
}
