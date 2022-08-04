import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_practice/providers/shareProvider.dart';

StateProvider<List<String>> wordListProvider = StateProvider((ref) => []);

void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Practice Riverpod",
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<String> wordList = ref.watch(wordListProvider);
    print("wordList: ${wordList.length}");

    if (wordList.isEmpty) {
      print("wordListは空です: ${wordList.length}");
      ShareProvider().getData(ref);
      print("wordList: ${wordList.length}");
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Todoリスト"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: TextField(
              controller: _textEditingController,
            ),
          ),
          Flexible(
            child: (wordList.isEmpty)
                ? const Center(
                    child: Text("なし"),
                  )
                : ListView.builder(
                    itemCount: wordList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Dismissible(
                        onDismissed: (direction) {
                          //directionとは
                          wordList.removeAt(index);
                          ref.read(wordListProvider.notifier).state = [
                            ...wordList
                          ];
                          ShareProvider().setData(wordList);
                        },
                        key: UniqueKey(),
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Card(
                            elevation: 10,
                            child: Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Text(wordList[index]),
                            ),
                          ),
                        ),
                      );
                    }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_textEditingController.text != "") {
            wordList.add(_textEditingController.text);
            ref.read(wordListProvider.notifier).state = [...wordList];
            //保存
            print("保存前のwordListの中身: $wordList");
            ShareProvider().setData(wordList);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
