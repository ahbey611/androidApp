import 'package:get_it/get_it.dart';
import './chat.dart';
import './search.dart';

final getIt = GetIt.instance;

void setupGetIt() {
  getIt.registerSingleton<ChatUserNotifier>(ChatUserNotifier());
  getIt.registerSingleton<ChatMessageNotifier>(ChatMessageNotifier());
  getIt.registerSingleton<SearchHistoryNotifier>(SearchHistoryNotifier());
  getIt.registerSingleton<SearchPostNotifier>(SearchPostNotifier());
}
