import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../provider/search.dart';
import '../../provider/get_it.dart';
// import '../../component/header.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  Widget searchHistoryData(int id, String content) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          debugPrint('print');
          searchHistoryController.text = content;
          final searchHistoryNotifier = GetIt.instance<SearchHistoryNotifier>();
          searchHistoryNotifier.updateSearchHistory(id);
          Navigator.pushNamed(
            context,
            '/searchPost',
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromRGBO(240, 240, 240, 1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 5, 10, 5),
            child: Row(
              children: <Widget>[
                Expanded(
                    // child: Text(content),
                    child: Text(content,
                        style: const TextStyle(
                          fontSize: 15,
                        ))),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    // Provider.of<SearchHistoryNotifier>(context, listen: false)
                    //     .deleteSearchHistory(content);
                    final searchHistoryNotifier =
                        GetIt.instance<SearchHistoryNotifier>();
                    searchHistoryNotifier.deleteSearchHistory(id);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 清空搜索历史
  Widget clearAllSearchHistory() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          final searchHistoryNotifier = GetIt.instance<SearchHistoryNotifier>();
          searchHistoryNotifier.deleteAllSearchHistory();
        },
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 61, 61),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Padding(
            padding: EdgeInsets.fromLTRB(15, 5, 10, 5),
            child: Text(
              '清空搜索历史',
              style: TextStyle(
                fontSize: 15,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    final searchHistoryNotifier = GetIt.instance<SearchHistoryNotifier>();
    searchHistoryNotifier.fetchSearchHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 250, 209, 252),
                Color.fromARGB(255, 255, 255, 255),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border(
              bottom: BorderSide(
                color: Color.fromRGBO(169, 171, 179, 1),
                width: 1,
              ),
            ),
          ),
          child: SizedBox(
            width: 100,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: TextField(
                controller: searchHistoryController,
                maxLength: 30,
                decoration: const InputDecoration(
                  hintText: '搜索...',
                  hintStyle: TextStyle(
                    color: Color.fromRGBO(169, 171, 179, 1),
                  ),
                  counterText: '',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                ),
                onSubmitted: (String value) {
                  // 搜索
                  final searchHistoryNotifier =
                      GetIt.instance<SearchHistoryNotifier>();
                  searchHistoryNotifier.addSearchHistory(value);
                  debugPrint(value);
                  Navigator.pushNamed(
                    context,
                    '/searchPost',
                  );
                  // searchHistoryController.clear();
                  // setState(() {});
                  // final searchPostNotifier =
                  //     GetIt.instance<SearchPostNotifier>();
                  // searchPostNotifier.fetchPostList(FilterType.NONE, value);
                  // setState(() {});
                },
              ),
            ),
          ),

          /* child: SizedBox(
            child: Row(children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.pop(context);
                },
                child: Text(
                  searchHistoryController.text,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Color.fromRGBO(169, 171, 179, 1),
                  ),
                ),
              )
            ]),
          ),
         */
        ),
      ),
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
          color: Colors.white,
        ),

        // 搜索栏
        child: Consumer(builder:
            (context, SearchHistoryNotifier searchHistoryNotifier, child) {
          if (searchHistoryNotifier.isFetching) {
            return Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                  color: Colors.pink, size: 25),
            );
          }

          return /*  Expanded(
            child: */
              SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
                // mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (searchHistoryNotifier.searchHistory.isNotEmpty)
                    clearAllSearchHistory(),
                  ...searchHistoryNotifier.searchHistory
                      .map((SearchHistory searchHistory) {
                    return searchHistoryData(
                        searchHistory.id, searchHistory.keyword);
                  }),
                ]),
          );
          //);
        }),
      ),
    );
  }
}
