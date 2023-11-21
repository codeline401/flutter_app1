import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  //Configure l'ensemble de l'application;
  //crée au niveau l'état de l'application
  //Nomme l'application et définit le thème visuel de l'app
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor:  Color.fromARGB(255, 67, 123, 187)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  //définit l'état d'intégrité de l'application
  //détermine les données dont l'application a besoin pour fonctionner

  var current = WordPair.random();

  //methode pour afficher le prochain mot aléatoire
  void getNext(){
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[]; //on va stocker dans un tableau
  //les mots que l'utilisateur va aimer

  void toggleFavorite(){
    //methode qui va se charger d'ajouter les éléments liké
    if (favorites.contains(current)){
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    //On envoie l'information d'état à tout les widget
    notifyListeners();
  }
}

/*class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //chaque widget définit une méthode build() automatiquement appelée
    //dès que les conditions du widget changent, pour être à jour

    //on appelle appState pour utiliser les methodes dans MyAppState
    var appState = context.watch<MyAppState>();

    var pair = appState.current;

    return Scaffold( //chaque méthode build doit renvoyer un widget
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, //pour centrer la vue
          children: [
            BigCard(pair: pair),

            //Séparer un peu plus les 2 widgets
            SizedBox(height: 10),
      
            //Ajout d'un bouton
            Row(
              mainAxisSize: MainAxisSize.min, //il ne doit pas utiliser 
              //tout l'espace horizontal
              children: [

                ElevatedButton.icon(onPressed: (){
                  appState.toggleFavorite();
                },
                icon: Icon(Icons.favorite), //icône de coeur
                label: Text('Like'),
                ),
                SizedBox(width: 10),

                ElevatedButton(
                  onPressed: (){
                    appState.getNext();
                  },
                  child: Text('Next')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
*/

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex){
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('no Widget for $selectedIndex');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
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
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
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
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite; //coeur plein
    } else {
      icon = Icons.favorite_border; //coeur vide
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite(); //On stocke les éléments
                  //dans le tableau favorites
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10), //ajouter un espacement entre les
              //deux bouttons
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

//Ajouter une autre page favories
class FavoritesPage extends StatelessWidget{

  @override
  Widget build(BuildContext context){
    var appState = context.watch<MyAppState>();

    if(appState.favorites.isEmpty){
      return Center(
        child: Text('No favorites yet'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child : Text('You have ${appState.favorites.length} favorites')
          ),
          for (var msg in appState.favorites)
            ListTile(
              leading: Icon(Icons.favorite),
              title: Text(msg.asLowerCase),
            ),
      ],
    );
  }
}



class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),

        child: Text(pair.asLowerCase, 
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}
