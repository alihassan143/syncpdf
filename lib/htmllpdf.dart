import 'dart:collection';
import 'dart:ui';

import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' show parse;
import 'package:pdf_sample/builin.dart';
import 'package:pdf_sample/enxtension.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'attrubutes.dart';

////html deocoder that deocde html and convert it into pdf widgets
class WidgetsHTMLDecoder {
  ///default font font the pdf if it not provided custo

  PdfDocument pdfdocument = PdfDocument();

  late PdfPage page;
  PdfTextElement textElement = PdfTextElement(text: "");
  late PdfTextLayoutResult layoutResult;
  String lastString = "";

  /// Fallback fonts

  //// The class takes an HTML string as input and returns a list of Widgets. The Widgets
  //// are created based on the tags and attributes in the HTML string.
  Future<List<int>> convert(String html) async {
    page = pdfdocument.pages.add();
    layoutResult = textElement.draw(
            page: page,
            bounds: Rect.fromLTWH(0, 0, page.getClientSize().width, 100))!
        as PdfTextLayoutResult;

    /// Parse the HTML document using the html package
    final document = parse(html.trim());
    final body = document.body;
    if (body == null) {
      return [];
    }

    /// Call the private _parseElement function to process the HTML nodes
    await _parseElement(body.nodes);

    final byes = await pdfdocument.save();
    pdfdocument.dispose();
    return byes;
  }

  //// Converts the given HTML string to a list of Widgets.
  //// and returns the list of widgets

  Future<void> _parseElement(
    Iterable<dom.Node> domNodes,
  ) async {
    ///find dom node in and check if its element or not than convert it according to its specs
    for (final domNode in domNodes) {
      if (domNode is dom.Element) {
        final localName = domNode.localName;
        if (localName == HTMLTags.br) {
          _drawText(text: "\n", styles: []);
        } else if (HTMLTags.formattingElements.contains(localName)) {
          /// Check if the element is a simple formatting element like <span>, <bold>, or <italic>
          final attributes = _parserFormattingElementAttributes(domNode);

          _drawText(
              text: "${domNode.text.replaceAll(RegExp(r'\n+$'), '')} ",
              brush: attributes.$3,
              alignment: attributes.$2,
              styles: attributes.$1);
        } else if (HTMLTags.specialElements.contains(localName)) {
          await _parseSpecialElements(
            domNode,
            type: BuiltInAttributeKey.bulletedList,
          );

          /// Handle special elements (e.g., headings, lists, images)
        }
      } else if (domNode is dom.Text) {
        _drawText(text: domNode.text, styles: []);

        /// Process text nodes and add them to delta
      } else {
        assert(false, 'Unknown node type: $domNode');
      }
    }

    /// If there are text nodes in delta, wrap them in a Wrap widget and add to the result

    return;
  }

  /// Function to parse special HTML elements (e.g., headings, lists, images)
  Future<void> _parseSpecialElements(
    dom.Element element, {
    required String type,
  }) async {
    final localName = element.localName;
    switch (localName) {
      /// Handle heading level 1
      case HTMLTags.h1:
        _parseHeadingElement(element, level: 1);

      /// Handle heading level 2
      case HTMLTags.h2:
        _parseHeadingElement(element, level: 2);

      /// Handle heading level 3
      case HTMLTags.h3:
        _parseHeadingElement(element, level: 3);

      /// Handle heading level 4
      case HTMLTags.h4:
        _parseHeadingElement(element, level: 4);

      /// Handle heading level 5
      case HTMLTags.h5:
        _parseHeadingElement(element, level: 5);

      /// Handle heading level 6
      case HTMLTags.h6:
        _parseHeadingElement(element, level: 6);

      /// Handle unorder list
      // case HTMLTags.unorderedList:
      //   _parseUnOrderListElement(element);

      // /// Handle ordered list and converts its childrens to widgets
      // case HTMLTags.orderedList:
      //   _parseOrderListElement(element);
      // // case HTMLTags.table:
      // //   _parseTable(element);

      // ///if simple list is found it will handle accoridingly
      // case HTMLTags.list:
      //   await _parseListElement(
      //     element,
      //     type: type,
      //   );

      /// it handles the simple paragraph element
      case HTMLTags.paragraph:
        await _parseDeltaElement(element);

      /// Handle block quote tag
      // case HTMLTags.blockQuote:
      //   _parseBlockQuoteElement(element);

      /// Handle the image tag
      // case HTMLTags.image:
      //   _parseImageElement(element);

      /// Handle the line break tag

      /// if no special element is found it treated as simple parahgraph
      default:
        await _parseDeltaElement(element);
    }
  }

  void paragraphNode({required String text}) {
    //     style: attributes.$2));
    _drawText(text: text.replaceAll(RegExp(r'\n+$'), ''), styles: []);
  }

  //// Parses the attributes of a formatting element and returns a TextStyle.
  (List<PdfFontStyle>, PdfTextAlignment?, PdfBrush?)
      _parserFormattingElementAttributes(dom.Element element) {
    final localName = element.localName;
    PdfTextAlignment? textAlign;
    PdfBrush? pdfBursh;

    final List<PdfFontStyle> decoration = [];
    switch (localName) {
      /// Handle <bold> element
      case HTMLTags.bold || HTMLTags.strong:
        decoration.add(PdfFontStyle.bold);
        break;

      /// Handle <em> <i> element
      case HTMLTags.italic || HTMLTags.em:
        decoration.add(PdfFontStyle.italic);

        break;

      /// Handle <u> element
      case HTMLTags.underline:
        decoration.add(PdfFontStyle.underline);
        break;

      /// Handle <del> element
      case HTMLTags.del:
        decoration.add(PdfFontStyle.strikethrough);

        break;

      /// Handle <span>  <mark> element
      case HTMLTags.span || HTMLTags.mark:
        final deltaAttributes = _getDeltaAttributesFromHtmlAttributes(
          element.attributes,
        );
        textAlign = deltaAttributes.$1;
        decoration.addAll(deltaAttributes.$2);
        pdfBursh = deltaAttributes.$3;
        break;

      /// Handle <a> element
      case HTMLTags.anchor:
        final href = element.attributes['href'];
        if (href != null) {
          decoration.add(
            PdfFontStyle.underline,
          );
        }
        break;

      /// Handle <code> element
      case HTMLTags.code:
        pdfBursh = PdfBrushes.red;
        break;
      default:
        break;
    }

    for (final child in element.children) {
      final nattributes = _parserFormattingElementAttributes(child);

      decoration.addAll(nattributes.$1);
    }

    ///will combine style get from the children
    return (decoration, textAlign, pdfBursh);
  }

  ///convert table tag into the table pdf widget
  // Future<Iterable<Widget>> _parseTable(dom.Element element) async {
  //   final List<TableRow> tablenodes = [];

  //   ///iterate over html table tag body
  //   for (final data in element.children) {
  //     final rwdata = await _parsetableRows(data);

  //     tablenodes.addAll(rwdata);
  //   }

  //   return [
  //     Table(
  //         border: TableBorder.all(color: PdfColors.black),
  //         children: tablenodes),
  //   ];
  // }

  ///converts html table tag body to table row widgets
  // Future<List<TableRow>> _parsetableRows(dom.Element element) async {
  //   final List<TableRow> nodes = [];

  //   ///iterate over <tr> tag and convert its children to related pdf widget
  //   for (final data in element.children) {
  //     final tabledata = await _parsetableData(data);

  //     nodes.add(tabledata);
  //   }
  //   return nodes;
  // }

  ///parse html data and convert to table row
  // Future<TableRow> _parsetableData(
  //   dom.Element element,
  // ) async {
  //   final List<Widget> nodes = [];

  //   ///iterate over <tr>children
  //   for (final data in element.children) {
  //     if (data.children.isEmpty) {
  //       ///if single <th> or<td> tag found
  //       final node = paragraphNode(text: data.text);

  //       nodes.add(node);
  //     } else {
  //       ///if nested <p><br> in <tag> found
  //       final newnodes = await _parseTableSpecialNodes(data);

  //       nodes.addAll(newnodes);
  //     }
  //   }

  //   ///returns the tale row
  //   return TableRow(
  //       decoration: BoxDecoration(border: Border.all(color: PdfColors.black)),
  //       children: nodes);
  // }

  // ///parse the nodes and handle theem accordingly
  // Future<Iterable<Widget>> _parseTableSpecialNodes(dom.Element element) async {
  //   final List<Widget> nodes = [];

  //   ///iterate over multiple childrens
  //   if (element.children.isNotEmpty) {
  //     for (final childrens in element.children) {
  //       ///parse them according to their widget
  //       nodes.addAll(await _parseTableDataElementsData(childrens));
  //     }
  //   } else {
  //     nodes.addAll(await _parseTableDataElementsData(element));
  //   }
  //   return nodes;
  // }

  // ///check if children contains the <p> <li> or any other tag

  // Future<List<Widget>> _parseTableDataElementsData(dom.Element element) async {
  //   final List<Widget> delta = [];
  //   final result = <Widget>[];

  //   ///find dom node in and check if its element or not than convert it according to its specs

  //   final localName = element.localName;

  //   /// Check if the element is a simple formatting element like <span>, <bold>, or <italic>
  //   if (localName == HTMLTags.br) {
  //   } else if (HTMLTags.formattingElements.contains(localName)) {
  //     final attributes = _parserFormattingElementAttributes(element);

  //     result.add(Text(element.text, style: attributes.$2));
  //   } else if (HTMLTags.specialElements.contains(localName)) {
  //     /// Handle special elements (e.g., headings, lists, images)
  //     result.addAll(
  //       await _parseSpecialElements(
  //         element,
  //         type: BuiltInAttributeKey.bulletedList,
  //       ),
  //     );
  //   } else if (element is dom.Text) {
  //     /// Process text nodes and add them to delta
  //     delta.add(Text(element.text,
  //         style: TextStyle(font: font, fontFallback: fontFallback)));
  //   } else {
  //     assert(false, 'Unknown node type: $element');
  //   }

  //   /// If there are text nodes in delta, wrap them in a Wrap widget and add to the result
  //   if (delta.isNotEmpty) {
  //     result.add(Wrap(children: delta));
  //   }
  //   return result;
  // }

  void _moveToNextLine() {
    textElement = PdfTextElement(
      text: "\n",
    );
    // Move to the next line by adjusting the Y-coordinate
    layoutResult = textElement.draw(
      page: page,
      bounds: Rect.fromLTWH(
        0, // Start at the left edge of the page
        layoutResult.lastLineBounds!.bottom + 10, // Move to the next line
        page.getClientSize().width, // Use the full width of the page
        100, // Height can be adjusted as needed
      ),
    ) as PdfTextLayoutResult;
  }

  void _drawText({
    required String text,
    PdfBrush? brush,
    PdfTextAlignment? alignment,
    required List<PdfFontStyle> styles,
    double fontSize = 12,
  }) {
    if (text.isEmpty || text.contains("\n")) {
      _moveToNextLine();
    }

    final double availableWidth = page.getClientSize().width;

    // Create a new PdfTextElement for the current text
    textElement = PdfTextElement(
      brush: brush,
      format: PdfStringFormat(alignment: alignment ?? PdfTextAlignment.left),
      font: PdfStandardFont(PdfFontFamily.timesRoman, fontSize,
          multiStyle: styles),
      text: " $text",
    );

    layoutResult = textElement.draw(
      page: page,
      bounds: Rect.fromLTWH(
        layoutResult.lastLineBounds!.right,
        layoutResult.lastLineBounds!.top,
        availableWidth,
        100, // Height can be adjusted as needed
      ),
    ) as PdfTextLayoutResult;
  }

  // /// Function to parse a heading element and return a RichText widget
  void _parseHeadingElement(
    dom.Element element, {
    required int level,
  }) {
    final children = element.nodes.toList();
    for (final child in children) {
      if (child is dom.Element) {
        final attributes = _parserFormattingElementAttributes(child);

        _drawText(
            text: "${child.text.replaceAll(RegExp(r'\n+$'), '')} ",
            brush: attributes.$3,
            fontSize: level.getHeadingSize,
            alignment: attributes.$2,
            styles: attributes.$1);
      } else {
        _drawText(
          text: child.text ?? "",
          styles: [PdfFontStyle.bold],
          fontSize: level.getHeadingSize,
        );
      }
    }

    /// Return a RichText widget with the parsed text and styles
  }

  /// Function to parse a block quote element and return a list of widgets
  // Future<List<Widget>> _parseBlockQuoteElement(dom.Element element) async {
  //   final result = <Widget>[];
  //   if (element.children.isNotEmpty) {
  //     for (final child in element.children) {
  //       result.addAll(
  //           await _parseListElement(child, type: BuiltInAttributeKey.quote));
  //     }
  //   } else {
  //     result.add(
  //         buildQuotewidget(Text(element.text), customStyles: customStyles));
  //   }
  //   return result;
  // }

  /// Function to parse an unordered list element and return a list of widgets
  // Future<void> _parseUnOrderListElement(dom.Element element) async {
  //   if (element.children.isNotEmpty) {
  //     for (final child in element.children) {
  //       await _parseListElement(child, type: BuiltInAttributeKey.bulletedList);
  //     }
  //   } else {
  //     PdfUnorderedList(
  //             text: element.text,
  //             style: PdfUnorderedMarkerStyle.disk,
  //             font: PdfStandardFont(PdfFontFamily.helvetica, 12),
  //             indent: 10,
  //             textIndent: 10,
  //             format: PdfStringFormat(lineSpacing: 10))
  //         .draw(
  //             page: pdfdocument.pages.add(),
  //             bounds: const Rect.fromLTWH(0, 10, 0, 0));

  //     layoutResult = textElement.draw(
  //         page: page,
  //         bounds: Rect.fromLTWH(
  //             layoutResult.lastLineBounds!.right,
  //             10,
  //             page.getClientSize().width - layoutResult.lastLineBounds!.right,
  //             100))! as PdfTextLayoutResult;
  //   }
  //   return;
  // }

  // /// Function to parse an ordered list element and return a list of widgets
  // Future<void> _parseOrderListElement(dom.Element element) async {

  //   if (element.children.isNotEmpty) {
  //     for (var i = 0; i < element.children.length; i++) {
  //       final child = element.children[i];
  //       result.addAll(await _parseListElement(child,
  //           type: BuiltInAttributeKey.numberList, index: i + 1));
  //     }
  //   } else {
  //     result.add(buildNumberwdget(Text(element.text),
  //         fontFallback: fontFallback, customStyles: customStyles, index: 1));
  //   }
  //   return result;
  // }

  // /// Function to parse a list element (unordered or ordered) and return a list of widgets
  // Future<void> _parseListElement(
  //   dom.Element element, {
  //   required String type,
  //   int? index,
  // }) async {
  //   final delta = await _parseDeltaElement(element);

  //   /// Build a bullet list widget
  //   if (type == BuiltInAttributeKey.bulletedList) {
  //     return [buildBulletwidget(delta, customStyles: customStyles)];

  //     /// Build a numbered list widget
  //   } else if (type == BuiltInAttributeKey.numberList) {
  //     return [
  //       buildNumberwdget(delta,
  //           index: index!,
  //           customStyles: customStyles,
  //           font: font,
  //           fontFallback: fontFallback)
  //     ];

  //     /// Build a quote  widget
  //   } else if (type == BuiltInAttributeKey.quote) {
  //     return [buildQuotewidget(delta, customStyles: customStyles)];
  //   } else {
  //     return [delta];
  //   }
  // }

  // /// Function to parse a paragraph element and return a widget

  // /// Function to parse an image element and download image as bytes  and return an Image widget
  // Future<void> _parseImageElement(dom.Element element) async {
  //   final src = element.attributes["src"];
  //   try {
  //     if (src != null) {
  //       final netImage = await _saveImage(src);
  //       return Image(MemoryImage(netImage),
  //           alignment: customStyles.imageAlignment);
  //     } else {
  //       return Text("");
  //     }
  //   } catch (e) {
  //     return Text("");
  //   }
  // }

  // /// Function to download and save an image from a URL
  // Future<Uint8List> _saveImage(String url) async {
  //   try {
  //     /// Download image
  //     final Response response = await get(Uri.parse(url));

  //     /// Get temporary directory

  //     return response.bodyBytes;
  //   } catch (e) {
  //     throw Exception(e);
  //   }
  // }

  /// Function to parse a complex HTML element and return a widget
  Future<void> _parseDeltaElement(dom.Element element) async {
    final children = element.nodes.toList();

    for (final child in children) {
      /// Recursively parse child elements
      if (child is dom.Element) {
        if (child.children.isNotEmpty &&
            HTMLTags.formattingElements.contains(child.localName) == false) {
          await _parseElement(child.children);
        } else {
          /// Handle special elements (e.g., headings, lists) within a paragraph
          if (HTMLTags.specialElements.contains(child.localName)) {
            await _parseSpecialElements(
              child,
              type: BuiltInAttributeKey.bulletedList,
            );
          } else {
            if (child.localName == HTMLTags.br) {
              _drawText(text: "\n", styles: []);
            } else {
              /// Parse text and attributes within the paragraph
              final attributes = _parserFormattingElementAttributes(child);

              _drawText(
                  text: "${child.text.replaceAll(RegExp(r'\n+$'), '')} ",
                  brush: attributes.$3,
                  alignment: attributes.$2,
                  styles: attributes.$1);
            }
          }
        }
      } else {
        final attributes =
            _getDeltaAttributesFromHtmlAttributes(element.attributes);

        _drawText(
            text: child.text?.replaceAll(RegExp(r'\n+$'), '') ?? "",
            brush: attributes.$3,
            alignment: attributes.$1,
            styles: attributes.$2);
      }
    }

    /// Create a column with wrapped text and child nodes
  }

  /// Utility function to convert a CSS string to a map of CSS properties
  static Map<String, String> _cssStringToMap(String? cssString) {
    final Map<String, String> result = {};
    if (cssString == null) {
      return result;
    }
    final entries = cssString.split(';');
    for (final entry in entries) {
      final tuples = entry.split(':');
      if (tuples.length < 2) {
        continue;
      }
      result[tuples[0].trim()] = tuples[1].trim();
    }
    return result;
  }

  (PdfTextAlignment?, List<PdfFontStyle>, PdfBrush?)
      _getDeltaAttributesFromHtmlAttributes(
          LinkedHashMap<Object, String> htmlAttributes) {
    List<PdfFontStyle> fontStyles = [];
    PdfTextAlignment? textAlign;
    PdfBrush? pdfBrush;

    ///extract styls from the inline css
    final styleString = htmlAttributes["style"];
    final cssMap = _cssStringToMap(styleString);

    ///get font weight
    final fontWeightStr = cssMap["font-weight"];
    if (fontWeightStr != null) {
      if (fontWeightStr == "bold") {
        fontStyles.add(PdfFontStyle.bold);
      } else {
        int? weight = int.tryParse(fontWeightStr);
        if (weight != null && weight > 500) {
          fontStyles.add(PdfFontStyle.italic);
        }
      }
    }

    ///apply different text decorations like undrline line through
    final textDecorationStr = cssMap["text-decoration"];
    if (textDecorationStr != null) {
      fontStyles.addAll(_assignTextDecorations(textDecorationStr));
    }

    ///apply background color on text
    final backgroundColorStr = cssMap["background-color"];
    final backgroundColor = backgroundColorStr == null
        ? null
        : ColorExtension.tryFromRgbaString(backgroundColorStr);
    if (backgroundColor != null) {
      pdfBrush = backgroundColor;
    }

    ///apply background color on text
    final colorstr = cssMap["color"];
    final color =
        colorstr == null ? null : ColorExtension.tryFromRgbaString(colorstr);
    if (color != null) {
      pdfBrush = color;
    }

    ///apply italic tag

    if (cssMap["font-style"] == "italic") {
      fontStyles.add(PdfFontStyle.italic);
    }
    final align = cssMap["text-align"];
    if (align != null) {
      textAlign = _alignText(align);
    }

    return (textAlign, fontStyles, pdfBrush);
  }

  static PdfTextAlignment _alignText(String alignmentString) {
    switch (alignmentString) {
      case "right":
        return PdfTextAlignment.right;
      case "center":
        return PdfTextAlignment.center;
      case "left":
        return PdfTextAlignment.right;

      case "justify":
        return PdfTextAlignment.justify;

      default:
        return PdfTextAlignment.left;
    }
  }

  ///this function apply thee text decorations from html inline style css
  static List<PdfFontStyle> _assignTextDecorations(String decorationStr) {
    final decorations = decorationStr.split(" ");
    final textdecorations = <PdfFontStyle>[];
    for (final d in decorations) {
      if (d == "line-through") {
        textdecorations.add(PdfFontStyle.strikethrough);
      } else if (d == "underline") {
        textdecorations.add(PdfFontStyle.underline);
      }
    }
    return textdecorations;
  }
}
