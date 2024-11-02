import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 28, 44, 185)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedPageIndex) {
      case 0:
        page = GeneratorPage();
      case 1:
        page = FavoritesPage();
      default:
        throw UnimplementedError('no widget for $selectedPageIndex');
    }
    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              extended: false,
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.favorite),
                  label: Text('Favorites'),
                ),
              ],
              selectedIndex: selectedPageIndex,
              onDestinationSelected: (value) {
                print('Page selected: $value');
                setState(() {
                  selectedPageIndex = value;
                });
              },
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: page,
            ),
          ),
        ],
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var namePair = appState.current;
    var favorites = appState.favorites;
    var likeBgColor = favorites.contains(namePair)
        ? const Color.fromARGB(255, 255, 149, 149)
        : Colors.white;
    var likeIcon =
        favorites.contains(namePair) ? Icons.favorite : Icons.favorite_border;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          BigCard(namePair: namePair),
          Row(mainAxisSize: MainAxisSize.min, children: [
            ElevatedButton.icon(
                style: ButtonStyle(
                    backgroundColor:
                        WidgetStatePropertyAll<Color>(likeBgColor)),
                onPressed: () {
                  appState.toggleFavorite();
                },
                label: Text('Like'),
                icon: Icon(likeIcon)),
            ElevatedButton(
              onPressed: () {
                appState.getNext();
              },
              child: Text('Next'),
            )
          ])
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.namePair,
  });

  final WordPair namePair;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var textStyle = theme.textTheme.displayMedium!
        .copyWith(color: Color.fromARGB(255, 255, 255, 255));
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          namePair.asLowerCase,
          style: textStyle,
          semanticsLabel: namePair.asPascalCase,
          selectionColor: Color.fromARGB(255, 177, 241, 238),
        ),
      ),
    );
  }
}

// ...

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var favorites = appState.favorites;
    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
        ),
        ...buildFavoriteWidgets(favorites)
      ],
    );
  }

  List<Widget> buildFavoriteWidgets(List<WordPair> favorites) {
    List<Widget> widgets = [];
    for (var item in favorites) {
      widgets.add(ListTile(
        leading: Icon(Icons.favorite),
        title: Text(item.asLowerCase),
      ));
    }
    return widgets;
  }
}
