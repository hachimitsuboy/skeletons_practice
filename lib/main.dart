import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_practice/providers/shareProvider.dart';

FutureProvider<List<String>> futureWordListProvider =
    FutureProvider((ref) async {
  //shared_preferencesから保存されているwordListを取り出す
  final getList = await ref.read(shareProvider).getData();
  ref.read(wordListProvider.notifier).state = getList;
  return getList;
});

StateProvider<List<String>> wordListProvider = StateProvider((ref) => []);

void main() {
  runApp(
    const ProviderScope(
      child: const MyApp(),
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
    final future = ref.watch(futureWordListProvider);
    final wordList = ref.watch(wordListProvider);

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
            child: future.when(
              data: (data) {
                return (data.isEmpty)
                    ? const Text("Todoなし")
                    : ListView.builder(
                        itemCount: wordList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Dismissible(
                            onDismissed: (direction) async {
                              wordList.removeAt(index);
                              ref.read(wordListProvider.notifier).state = [
                                ...wordList
                              ];
                              await ref.read(shareProvider).setData(wordList);
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
                        },
                      );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (Object error, StackTrace? stackTrace) => Center(
                child: Text("エラー: $error"),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_textEditingController.text != "") {
            wordList.add(_textEditingController.text);
            ref.read(wordListProvider.notifier).state = [...wordList];
            print(wordList);
            await ref.read(shareProvider).setData(wordList);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
