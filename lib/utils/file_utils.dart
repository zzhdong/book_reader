import 'dart:io';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:book_reader/utils/string_utils.dart';

class FileUtils {
  static const int BLANK = 0x0a;

  //采用自己的格式去设置文件，防止文件被系统文件查询到
  static const String SUFFIX_CUSTOM = ".topf";
  static const String SUFFIX_TXT = ".txt";
  static const String SUFFIX_EPUB = ".epub";
  static const String SUFFIX_PDF = ".pdf";

  //获取文件夹
  static Directory createDirectory(String dirPath) {
    Directory tmpDir = Directory(dirPath);
    if (!tmpDir.existsSync()) tmpDir.createSync(recursive: true);
    return tmpDir;
  }

  //获取文件
  static File createFile(String filePath) {
    File file = File(filePath);
    try {
      if (!file.existsSync()) {
        //创建父类文件夹
        createDirectory(file.parent.path);
        //创建文件
        file.createSync(recursive: true);
      }
    } catch (e) {}
    return file;
  }

  //获取目录大小
  static double getTotalSizeOfFilesInDir(final FileSystemEntity file) {
    try{
      if (file is File) {
        int length = file.lengthSync();
        return double.parse(length.toString());
      }
      if (file is Directory) {
        final List<FileSystemEntity> children = file.listSync();
        double total = 0;
        for (final FileSystemEntity child in children) {
          total += getTotalSizeOfFilesInDir(child);
        }
        return total;
      }
      return 0;
    }catch(e){
      return 0;
    }
  }

  static String formatMb(double size){
    final formatter = NumberFormat("0.00");
    return "${formatter.format(size / 1024 / 1024)}M";
  }

  static String formatFileSize(double size) {
    if (size <= 0) return "0";
    final List<String> units = ["b", "kb", "M", "G", "T"];
    //计算单位的，原理是利用lg,公式是 lg(1024^n) = nlg(1024)，最后 nlg(1024)/lg(1024) = n。
    double digitGroups = (log(size) / log(1024));
    //计算原理是，size/单位值。单位值指的是:比如说b = 1024,KB = 1024^2
    final formatter = NumberFormat("0.00");
    return "${formatter.format(size / pow(1024, digitGroups))} ${units[digitGroups.toInt()]}";
  }

  //本来是获取File的内容的。但是为了解决文本缩进、换行的问题 这个方法就是专门用来获取书籍的...
  static String getFileContent(File file) {
    List<String> contentList = file.readAsLinesSync();
    StringBuffer sb = StringBuffer();
    for (String content in contentList) {
      //过滤空语句
      if (!StringUtils.isEmpty(content)) {
        //由于sb会自动过滤\n,所以需要加上去
        sb.write("    $content\n");
      }
    }
    return sb.toString();
  }

  //递归删除文件夹下的数据
  static void deleteFile(String path) {
    if(FileSystemEntity.isDirectorySync(path)){
      Directory tmpDir = Directory(path);
      if (!tmpDir.existsSync()) return;
      tmpDir.deleteSync(recursive: true);
    }else{
      File file = File(path);
      if (!file.existsSync()) return;
      file.deleteSync(recursive: true);
    }
  }

  //获取文件后缀
  static String getFileSuffix(String filePath) {
    if (StringUtils.isEmpty(filePath)) return "";
    File file = File(filePath);
    if (!file.existsSync() || FileSystemEntity.isDirectorySync(filePath)) {
      return "";
    }
    String fileName = path.basename(file.path);
    int dotIndex = fileName.lastIndexOf(".");
    return dotIndex > 0 ? fileName.substring(dotIndex) : "";
  }

  //获取txt文件, 由于递归的耗时问题，取巧只遍历内部三层
  static List<File> getTxtFiles(String filePath, int layer) {
    List<File> txtFiles = [];
    File file = File(filePath);
    //如果层级为 3，则直接返回
    if (layer == 3) {
      return txtFiles;
    }
    //如果是目录则递归计算其内容的总大小
    FileStat fileStat = file.statSync();
    if (fileStat.type == FileSystemEntityType.directory) {
      Directory tmpDir = Directory(file.path);
      List<FileSystemEntity> list = tmpDir.listSync();
      for (FileSystemEntity fileSystemEntity in list) {
        txtFiles.addAll(getTxtFiles(fileSystemEntity.path, layer + 1));
      }
      return txtFiles;
    } else {
      if (file.path.endsWith(".txt")) txtFiles.add(file);
      return txtFiles;
    }
  }
}
