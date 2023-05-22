import 'dart:collection';
import 'package:html/dom.dart';
import 'package:book_reader/plugin/soup_plugin.dart';
import 'package:book_reader/utils/regex_utils.dart';
import 'package:book_reader/utils/string_utils.dart';
import 'package:book_reader/plugin/xpath_plugin.dart';

class AnalyzeBySoup {

  late Element _element;

  AnalyzeBySoup parse(final Object doc) {
    if (doc is Element) {
      _element = doc;
    } else if (doc is List<Element>) {
      String html = "";
      for (Element el in doc) {
        html += el.outerHtml;
      }
      _element = strToElement(html);
    } else if (doc is Document) {
      _element = doc.documentElement!;
    } else if (doc is XDocument) {
      _element = strToElement(doc.getHtml());
    } else if (doc is XNode) {
      _element = strToElement(doc.getNodeText());
    } else if (doc is List<XNode>) {
      String html = "";
      for (XNode el in doc) {
        html += el.getNodeText();
      }
      _element = strToElement(html);
    } else {
      _element = strToElement(doc.toString());
    }
    return this;
  }

  //字符串转对象
  Element strToElement(String str){
    String complementHtml = StringUtils.complementHtml(str);
    Element? element;
    try{
      element = Element.html(complementHtml);
      //判断是否需要补存标签
      element = StringUtils.addTableTag(element.localName ?? "", element.outerHtml);
    }catch(e){
      element = Document.html(complementHtml).documentElement;
    }
    return element!;
  }

  // 合并内容列表,得到内容
  Future<String> getString(final String ruleStr) async{
    if (StringUtils.isEmpty(ruleStr)) {
      return "";
    }
    List<String> textList = await getStringList(ruleStr);
    if (textList.isEmpty) {
      return "";
    }
    return StringUtils.strJoin(textList, ",").trim();
  }

  // 获取一个字符串
  Future<String> getStringFirstIndex(final String ruleStr) async{
    List<String> textList = await getStringList(ruleStr);
    if (textList.isNotEmpty) {
      return textList[0].trim();
    }
    return "";
  }

  // 获取所有内容列表
  Future<List<String>> getStringList(final String ruleStr) async {
    List<String> textList = [];
    if (StringUtils.isEmpty(ruleStr)) {
      return textList;
    }
    //拆分规则
    SourceRule sourceRule = SourceRule(ruleStr);
    if (StringUtils.isEmpty(sourceRule.elementsRule)) {
      textList.add(_element.text.trim());
    } else {
      String elementsType;
      List<String> ruleStrList = [];
      if (sourceRule.elementsRule.contains("&")) {
        elementsType = "&";
        ruleStrList = sourceRule.elementsRule.split(RegExp("&+"));
      } else if (sourceRule.elementsRule.contains("%%")) {
        elementsType = "%";
        ruleStrList = sourceRule.elementsRule.split(RegExp("%%"));
      } else {
        elementsType = "|";
        if (sourceRule.isCss) {
          ruleStrList = sourceRule.elementsRule.split(RegExp("\\|\\|"));
        } else {
          ruleStrList = sourceRule.elementsRule.split(RegExp("\\|+"));
        }
      }
      List<List<String>> results = [];
      for (String rule in ruleStrList) {
        List<String> tempList;
        if (sourceRule.isCss) {
          int lastIndex = rule.lastIndexOf('@');
          tempList = getResultLast(await SoupPlugin.selectElement(_element.outerHtml, rule.substring(0, lastIndex)), rule.substring(lastIndex + 1));
        } else {
          tempList = await getResultList(rule);
        }
        if (tempList.isNotEmpty) {
          results.add(tempList);
          if (results.isNotEmpty && elementsType == "|") {
            break;
          }
        }
      }
      if (results.isNotEmpty) {
        if ("%" == elementsType) {
          for (int i = 0; i < results[0].length; i++) {
            for (List<String> tempList in results) {
              if (i < tempList.length) {
                textList.add(tempList[i]);
              }
            }
          }
        } else {
          for (List<String> tempList in results) {
            textList.addAll(tempList);
          }
        }
      }
    }
    if (!StringUtils.isEmpty(sourceRule.replaceRegex)) {
      List<String> tempList = List<String>.filled(textList.length, '');
      List.copyRange(tempList, 0, textList, 0, textList.length);
      textList.clear();
      for (String text in tempList) {
        RegExp exp = RegexUtils.getRegExp(sourceRule.replaceRegex);
        if(exp.hasMatch(text)) {
          text = StringUtils.ruleReplaceAll(text, sourceRule.replaceRegex, sourceRule.replacement);
        }
        if (text.isNotEmpty) {
          textList.add(text);
        }
      }
    }
    return textList;
  }

  Future<List<Element>> getElements(final String rule, {Element? element}) async {
    element ??= _element.clone(true);
    List<Element> elements = [];
    if (StringUtils.isEmpty(rule)) {
      return elements;
    }
    SourceRule sourceRule = SourceRule(rule);
    String elementsType;
    List<String> ruleStrList;
    if (sourceRule.elementsRule.contains("&")) {
      elementsType = "&";
      ruleStrList = sourceRule.elementsRule.split(RegExp("&+"));
    } else if (sourceRule.elementsRule.contains("%")) {
      elementsType = "%";
      ruleStrList = sourceRule.elementsRule.split(RegExp("%+"));
    } else {
      elementsType = "|";
      if (sourceRule.isCss) {
        ruleStrList = sourceRule.elementsRule.split(RegExp("\\|\\|"));
      } else {
        ruleStrList = sourceRule.elementsRule.split(RegExp("\\|+"));
      }
    }
    List<List<Element>> elementsList = [];
    if (sourceRule.isCss) {
      for (String ruleStr in ruleStrList) {
        List<Element> tmpList = await SoupPlugin.selectElement(element.outerHtml, ruleStr);
        elementsList.add(tmpList);
        if (tmpList.isNotEmpty && elementsType == "|") {
          break;
        }
      }
    } else {
      for (String ruleStr in ruleStrList) {
        List<Element> elementList = await getElementsSingle(element, ruleStr);
        elementsList.add(elementList);
        if (elementList.isNotEmpty && elementsType == "|") {
          break;
        }
      }
    }
    if (elementsList.isNotEmpty) {
      if ("%" == elementsType) {
        for (int i = 0; i < elementsList[0].length; i++) {
          for (List<Element> es in elementsList) {
            if (i < es.length) {
              elements.add(es[i]);
            }
          }
        }
      } else {
        for (List<Element> es in elementsList) {
          elements.addAll(es);
        }
      }
    }
    return elements;
  }

  List<Element> filterElements(List<Element> elements, List<String> ruleList) {
    if (ruleList.length < 2) return elements;
    List<Element> selectedEls = [];
    for (Element ele in elements) {
      bool isOk = false;
      switch (ruleList[0]) {
        case "class":
          if(ele.children.isEmpty || ele.className == ruleList[1]){
            ele = StringUtils.addTableTag(ele.localName ?? "", ele.outerHtml, parentTag: "div")!;
          }
          isOk = ele.getElementsByClassName(ruleList[1]).isNotEmpty;
          break;
        case "id":
          if(ele.children.isEmpty || ele.id == ruleList[1]){
            ele = StringUtils.addTableTag(ele.localName ?? "", ele.outerHtml, parentTag: "div")!;
          }
          isOk = ele.querySelectorAll("#${ruleList[1]}").isNotEmpty;
          break;
        case "tag":
          if(ruleList[1].toLowerCase() == "html"){
            isOk = true;
          }else{
            if(ele.children.isEmpty || ele.localName == ruleList[1]){
              ele = StringUtils.addTableTag(ele.localName ?? "", ele.outerHtml, parentTag: "div")!;
            }
            isOk = ele.getElementsByTagName(ruleList[1]).isNotEmpty;
          }
          break;
        case "text":
          isOk = getElementsContainingOwnText(ele.nodes, ruleList[1]).isNotEmpty;
          break;
      }
      if (isOk) {
        selectedEls.add(ele);
      }
    }
    return selectedEls;
  }

  // 获取Elements按照一个规则
  Future<List<Element>> getElementsSingle(Element tempElement, String tempRule) async {
    List<Element> elements = [];
    try {
      List<String> rsList = tempRule.trim().split(RegExp("@"));
      if (rsList.length > 1) {
        elements.add(tempElement);
        for (String rule in rsList) {
          List<Element> elementList = [];
          for (Element et in elements) {
            elementList.addAll(await getElements(rule, element: et));
          }
          elements.clear();
          elements.addAll(elementList);
        }
      } else {
        List<String> ruleExcludeTmp = tempRule.trim().split(RegExp("!"));
        //如果最后一项为空，则移除
        if(StringUtils.isEmpty(ruleExcludeTmp.last)) ruleExcludeTmp.removeLast();
        List<String> ruleExcludeList = ruleExcludeTmp[0].trim().split(RegExp(">"));
        List<String> ruleList = ruleExcludeList[0].trim().split(RegExp("\\."));
        //如果最后一项为空，则移除
        if(StringUtils.isEmpty(ruleList.last)) ruleList.removeLast();
        List<String> filterRuleList = [];
        bool needFilterElements = ruleExcludeList.length > 1 && !StringUtils.isEmpty(ruleExcludeList[1].trim());
        if (needFilterElements) {
          filterRuleList = ruleExcludeList[1].trim().split(RegExp("\\."));
          filterRuleList[0] = filterRuleList[0].trim();
          List<String> validKeys = ["class", "id", "tag", "text"];
          if (filterRuleList.length < 2 ||
              !validKeys.contains(filterRuleList[0]) ||
              StringUtils.isEmpty(filterRuleList[1])) {
            needFilterElements = false;
          }else{
            filterRuleList[1] = filterRuleList[1].trim();
          }
        }
        switch (ruleList[0]) {
          case "children":
            List<Element> children = tempElement.children;
            if (needFilterElements) children = filterElements(children, filterRuleList);
            elements.addAll(children);
            break;
          case "class":
            if(tempElement.children.isEmpty || tempElement.className == ruleList[1]){
              tempElement = StringUtils.addTableTag(tempElement.localName ?? "", tempElement.outerHtml, parentTag: "div")!;
            }
            List<Element> elementsByClass = tempElement.getElementsByClassName(ruleList[1]);
            if(elementsByClass.isEmpty) break;
            if (ruleList.length == 3) {
              int index = StringUtils.stringToInt(ruleList[2], def: -1);
              if (index < 0) {
                if((elementsByClass.length + index) < elementsByClass.length && (elementsByClass.length + index) >= 0) {
                  elements.add(elementsByClass[elementsByClass.length + index]);
                }
              } else {
                if(index < elementsByClass.length && index >= 0) {
                  elements.add(elementsByClass[index]);
                }
              }
            } else {
              if (needFilterElements) elementsByClass = filterElements(elementsByClass, filterRuleList);
              elements.addAll(elementsByClass);
            }
            break;
          case "tag":
            if(ruleList[1].toLowerCase() == "html"){
              elements.add(tempElement);
            }else{
              //由于是从下一级开始查询，因此需要判断是否在外面加一层
              if(tempElement.children.isEmpty || tempElement.localName == ruleList[1]){
                tempElement = StringUtils.addTableTag(tempElement.localName ?? "", tempElement.outerHtml, parentTag: "div")!;
              }
              List<Element> elementsByTag = tempElement.getElementsByTagName(ruleList[1]);
              if(elementsByTag.isEmpty) break;
              if (ruleList.length == 3) {
                int index = StringUtils.stringToInt(ruleList[2], def: -1);
                if (index < 0) {
                  if((elementsByTag.length + index) < elementsByTag.length && (elementsByTag.length + index) >= 0) {
                    elements.add(elementsByTag[elementsByTag.length + index]);
                  }
                } else {
                  if(index < elementsByTag.length && index >= 0) {
                    elements.add(elementsByTag[index]);
                  }
                }
              } else {
                if (needFilterElements) elementsByTag = filterElements(elementsByTag, filterRuleList);
                elements.addAll(elementsByTag);
              }
            }
            break;
          case "id":
            if(tempElement.children.isEmpty || tempElement.id == ruleList[1]){
              tempElement = StringUtils.addTableTag(tempElement.localName ?? "", tempElement.outerHtml, parentTag: "div")!;
            }
            List<Element> elementsById = tempElement.querySelectorAll("#${ruleList[1]}");
            if(elementsById.isEmpty) break;
            if (ruleList.length == 3) {
              int index = StringUtils.stringToInt(ruleList[2], def: -1);
              if (index < 0) {
                if((elementsById.length + index) < elementsById.length && (elementsById.length + index) >= 0) {
                  elements.add(elementsById[elementsById.length + index]);
                }
              } else {
                if(index < elementsById.length && index >= 0) {
                  elements.add(elementsById[index]);
                }
              }
            } else {
              if (needFilterElements) elementsById = filterElements(elementsById, filterRuleList);
              elements.addAll(elementsById);
            }
            break;
          case "text":
            List<Element> elementsByText = getElementsContainingOwnText(tempElement.nodes, ruleList[1]);
            if(elementsByText.isEmpty) break;
            if (needFilterElements) elementsByText = filterElements(elementsByText, filterRuleList);
            elements.addAll(elementsByText);
            break;
          default:
            elements.addAll(await SoupPlugin.selectElement(tempElement.outerHtml, ruleExcludeTmp[0]));
        }
        if (ruleExcludeTmp.length > 1) {
          List<String> tmpList = ruleExcludeTmp[1].split(RegExp(":"));
          for (String str in tmpList) {
            int tmpInt = StringUtils.stringToInt(str);
            if (tmpInt < 0 && elements.length + tmpInt >= 0) {
              //elements[elements.length + tmpInt] = null;
            } else if (tmpInt < elements.length) {
              //elements[tmpInt] = null;
            }
          }
          List<Element> resultElement = [];
          for (Element el in elements) {
            resultElement.add(el);
          }
          elements = resultElement;
        }
      }
    } catch (e) {print(e);}
    return elements;
  }

  //递归获取
  List<Element> getElementsContainingOwnText(NodeList nodeList, String key){
    List<Element> nodeRetList = [];
    for (int i = 0; i < nodeList.length; i++) {
      if(nodeList[i].nodes.isEmpty){
        if(nodeList[i].text?.contains(key) ?? false) nodeRetList.add(nodeList[i].parent!);
      }else{
        nodeRetList.addAll(getElementsContainingOwnText(nodeList[i].nodes, key));
      }
    }
    return nodeRetList;
  }

  // 获取内容列表
  Future<List<String>> getResultList(String ruleStr) async{
    if (StringUtils.isEmpty(ruleStr)) {
      return [];
    }
    List<Element> elements = [];
    elements.add(_element);
    List<String> ruleList = ruleStr.split(RegExp("@"));
    for (int i = 0; i < ruleList.length - 1; i++) {
      List<Element> es = [];
      for (Element elt in elements) {
        es.addAll(await getElementsSingle(elt, ruleList[i]));
      }
      elements.clear();
      elements = es;
    }
    if (elements.isEmpty) {
      return [];
    }
    return getResultLast(elements, ruleList[ruleList.length - 1]);
  }

  /// 根据最后一个规则获取内容
  List<String> getResultLast(List<Element> elementsList, String lastRule) {
    List<String> resultList = [];
    List<String> textList = [];
    //复制列表
    List<Element> elements = [];
    for(Element el in elementsList){
      elements.add(el.clone(true));
    }
    try {
      switch (lastRule) {
        case "text":
          //移除script
          for (Element element in elements) {
            List<Element> tmpList = element.querySelectorAll("script");
            for(Element tmpElement in tmpList) {
              tmpElement.remove();
            }
          }
          for (Element element in elements) {
            //多个空格替换为一个空格
            textList.add(element.text.trim().replaceAll(RegExp("\\s+"), " "));
          }
          resultList.add(StringUtils.strJoin(textList, "\n"));
          break;
        case "textNodes":
          for (Element element in elements) {
            //移除子节点，只获取当前文本
            for(Node node in element.children){
              node.remove();
            }
            for(Node node in element.nodes){
              //过滤注释和空数据
              if(!StringUtils.isEmpty(node.text?.trim() ?? "") && !node.toString().startsWith("<!--")){
                textList.add(node.text?.trim() ?? "");
              }
            }
          }
          resultList.add(StringUtils.strJoin(textList, "\n"));
          break;
        case "ownText":
          for (Element element in elements) {
            for(Node node in element.children){
              node.remove();
            }
            if(!StringUtils.isEmpty(element.text.trim())) {
              textList.add(element.text.trim());
            }
          }
          resultList.add(StringUtils.strJoin(textList, "\n"));
          break;
        case "html":
          //移除script
          for (Element element in elements) {
            List<Element> tmpList = element.querySelectorAll("script");
            for(Element tmpElement in tmpList) {
              tmpElement.remove();
            }
          }
          StringBuffer html = StringBuffer();
          for (Element element in elements) {
            if(element.innerHtml.isNotEmpty) html.write("\n");
            html.write(element.innerHtml);
          }
          resultList.add(html.toString());
          break;
        default:
          for (Element element in elements) {
            //先添加自身的属性判断
            LinkedHashMap<dynamic, String> attributes = element.attributes;
            String url = attributes[lastRule] ?? "";
            if (!StringUtils.isEmpty(url) && !resultList.contains(url)) {
              resultList.add(url.replaceAll("\r", "").replaceAll("\n", "").replaceAll(" ", "").replaceAll("　", ""));
            }
          }
      }
    } catch (e) {print(e);}
    return resultList;
  }
}

class SourceRule {
  bool isCss = false;
  late String elementsRule;
  String replaceRegex = "";
  String replacement = "";

  SourceRule(String ruleStr) {
    if (StringUtils.startWithIgnoreCase(ruleStr, "@CSS:")) {
      isCss = true;
      elementsRule = ruleStr.substring(5).trim();
      return;
    }
    List<String> ruleStrList = [];
    //分离正则表达式
    ruleStrList = ruleStr.trim().split(RegExp("#"));
    elementsRule = ruleStrList[0];
    if (ruleStrList.length > 1) {
      replaceRegex = ruleStrList[1];
    }
    if (ruleStrList.length > 2) {
      replacement = ruleStrList[2];
    }
  }
}
