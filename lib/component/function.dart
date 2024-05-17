import 'package:flutter/material.dart';

// 提取日期时间
String extractDateTime(String dateTime) {
  String date = dateTime.split(' ')[0];
  String time = dateTime.split(' ')[1];
  String year = date.split('-')[0];
  String month = date.split('-')[1];
  String day = date.split('-')[2];
  String today = DateTime.now().toString().split(' ')[0];
  String thisYear = DateTime.now().toString().split(' ')[0].split('-')[0];
  String formattedTime = '';
  if (date == today) {
    formattedTime = time;
  } else if (year == thisYear) {
    formattedTime = '$month-$day';
  } else {
    formattedTime = '$year-$month-$day';
  }
  return formattedTime;
}

// 检查并裁剪文本的函数
String checkAndFormatContent(String content, double maxWidth, TextStyle style) {
  TextPainter textPainter = TextPainter(
    text: TextSpan(text: content, style: style),
    maxLines: 1,
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: maxWidth);

  if (textPainter.didExceedMaxLines) {
    // 如果文本超出了最大行数，需要裁剪
    for (int i = content.length; i > 0; i--) {
      String testString = '${content.substring(0, i)}...';
      textPainter.text = TextSpan(text: testString, style: style);
      textPainter.layout(maxWidth: maxWidth);

      if (!textPainter.didExceedMaxLines) {
        // 找到不超出最大宽度的裁剪位置
        return testString;
      }
    }
  }

  return content; // 文本没有超出最大宽度
}
