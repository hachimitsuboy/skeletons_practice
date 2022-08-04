import 'package:riverpod_practice/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



class ShareProvider {


  //保存
  Future<void> setData(List<String> wordList) async {
    print("保存メソッド内でのwordList: $wordList");
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList("todos", wordList);

    //TODO 保存されてはいる
    final check = prefs.getStringList("todos") ?? ["入ってないよ"];
    print("チェック: $check");
  }

  //ロード
  Future<void> getData(WidgetRef ref) async {
    final prefs = await SharedPreferences.getInstance();
    //保存されているリストがある場合、ない場合で場合分する必要がある
    final returnWordList = prefs.getStringList("todos") ?? ["入ってないよ"];
    ref.read(wordListProvider.notifier).state = returnWordList;
  }
}