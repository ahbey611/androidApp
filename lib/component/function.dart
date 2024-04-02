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
