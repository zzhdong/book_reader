import 'package:html/dom.dart';
import 'package:book_reader/plugin/xpath_plugin.dart';
import 'package:book_reader/utils/string_utils.dart';

class AnalyzeByXPath {
  late XDocument _xDocument;

  AnalyzeByXPath parse(Object doc) {
    if (doc is XNode) {
      _xDocument = strToDocument(doc.getNodeText());
    } else if (doc is List<XNode>) {
      String html = "";
      for (XNode el in doc) {
        html += el.getNodeText();
      }
      _xDocument = strToDocument(html);
    } else if (doc is XDocument) {
      _xDocument = doc;
    } else if (doc is Document) {
      _xDocument = strToDocument(doc.outerHtml);
    } else if (doc is Element) {
      _xDocument = strToDocument(doc.outerHtml);
    } else if (doc is List<Element>) {
      String html = "";
      for (Element el in doc) {
        html += el.outerHtml;
      }
      _xDocument = strToDocument(html);
    } else {
      _xDocument = strToDocument(doc.toString());
    }
    return this;
  }

  XDocument strToDocument(String html) {
    if (html.endsWith("</td>")) {
      html = "<tr>$html</tr>";
    } else if (html.endsWith("</tr>") || html.endsWith("</tbody>")) {
      html = "<table>$html</table>";
    } else {
      html = "<html lang=\"\">$html</html>";
    }
    return XDocument(html);
  }

  Future<List<XNode>> getElements(String xPath) async {
    if (StringUtils.isEmpty(xPath)) {
      return [];
    }
    List<XNode> xNodeList = [];
    String elementsType;
    List<String> rules;
    if (xPath.contains("&&")) {
      rules = xPath.split(RegExp("&&"));
      elementsType = "&";
    } else if (xPath.contains("%%")) {
      rules = xPath.split(RegExp("%%"));
      elementsType = "%";
    } else {
      rules = xPath.split(RegExp("\\|\\|"));
      elementsType = "|";
    }
    if (rules.length == 1) {
      return await _xDocument.selectNodesXml(rules[0]);
    } else {
      List<List<XNode>> results = [];
      for (String rl in rules) {
        List<XNode> tempNodeList = await getElements(rl);
        if (tempNodeList.isNotEmpty) {
          results.add(tempNodeList);
          if (tempNodeList.isNotEmpty && elementsType == "|") {
            break;
          }
        }
      }
      if (results.isNotEmpty) {
        if ("%" == elementsType) {
          for (int i = 0; i < results[0].length; i++) {
            for (List<XNode> temp in results) {
              if (i < temp.length) {
                xNodeList.add(temp[i]);
              }
            }
          }
        } else {
          for (List<XNode> temp in results) {
            xNodeList.addAll(temp);
          }
        }
      }
    }
    return xNodeList;
  }

  Future<List<String>> getStringList(String xPath) async{
    List<String> result = [];
    String elementsType;
    List<String> rules;
    if (xPath.contains("&&")) {
      rules = xPath.split(RegExp("&&"));
      elementsType = "&";
    } else if (xPath.contains("%%")) {
      rules = xPath.split(RegExp("%%"));
      elementsType = "%";
    } else {
      rules = xPath.split(RegExp("\\|\\|"));
      elementsType = "|";
    }
    if (rules.length == 1) {
      return await _xDocument.selectNodesValue(xPath);
    } else {
      List<List<String>> results = [];
      for (String rl in rules) {
        List<String> temp = await getStringList(rl);
        if (temp.isNotEmpty) {
          results.add(temp);
          if (temp.isNotEmpty && elementsType == "|") {
            break;
          }
        }
      }
      if (results.isNotEmpty) {
        if ("%" == elementsType) {
          for (int i = 0; i < results[0].length; i++) {
            for (List<String> temp in results) {
              if (i < temp.length) {
                result.add(temp[i]);
              }
            }
          }
        } else {
          for (List<String> temp in results) {
            result.addAll(temp);
          }
        }
      }
    }
    return result;
  }

  Future<String> getString(String rule) async {
    List<String> rules = [];
    String elementsType;
    if (rule.contains("&&")) {
      rules = rule.split(RegExp("&&"));
      elementsType = "&";
    } else {
      rules = rule.split(RegExp("\\|\\|"));
      elementsType = "|";
    }
    if (rules.length == 1) {
      List<String> retList = await _xDocument.selectNodesValue(rule);
      return StringUtils.strJoin(retList, ",");
    } else {
      List<String> textList = [];
      for (String rl in rules) {
        String temp = await getString(rl);
        if (!StringUtils.isEmpty(temp)) {
          textList.add(temp);
          if (elementsType == "|") {
            break;
          }
        }
      }
      return StringUtils.strJoin(textList, ",").trim();
    }
  }
}
