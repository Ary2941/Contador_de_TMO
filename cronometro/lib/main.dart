import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Cronometro',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  List<int> lista = [];
  int listaAll = 0;

  var counter = false;
  int current = 0;

  void refreshList(int newvalue) {
    if (counter) {
      listaAll += newvalue - current;
      lista.add(newvalue - current);
      current = newvalue;
      counter = !counter;
    } else {
      current = newvalue;
      counter = !counter;
    }

    notifyListeners();
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 87, 120, 87),
        appBar: AppBar(
          title: const Text("Contador de TMO"),
        ),
        body: Center(
            child: Column(
          children: [
            ClockWidget2(),
            ElevatedButton(
              onPressed: () {
                if (appState.counter) {
                  showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                              title: const Text('Ligação encerrada?'),
                              content:
                                  const Text('o cliente/atendente encerrou'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, "AlarmeFalso"),
                                  child: const Text('Não'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    var x = (DateTime.now().hour * 60 +
                                                DateTime.now().minute) *
                                            60 +
                                        DateTime.now().second;
                                    appState.refreshList(x);
                                    print(appState.lista);
                                    Navigator.pop(context, "EncerrouLigação");
                                  },
                                  child: const Text('Sim'),
                                ),
                              ]));
                } else {
                  var x =
                      (DateTime.now().hour * 60 + DateTime.now().minute) * 60 +
                          DateTime.now().second;
                  appState.refreshList(x);
                  print(appState.lista);
                }
              },
              child: const Text('ON/OFF'),
            ),
            ClockWidget(),
          ],
        )));
  }
}

class ClockWidget extends StatelessWidget {
  const ClockWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        return Text(DateFormat('MM/dd/yyyy hh:mm:ss').format(DateTime.now()));
      },
    );
  }
}

class ClockWidget2 extends StatelessWidget {
  const ClockWidget2({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!
        .copyWith(color: theme.colorScheme.onPrimary);

    var appState = context.watch<MyAppState>();
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        int y = (DateTime.now().hour * 60 + DateTime.now().minute) * 60 +
            DateTime.now().second;

        if (appState.counter) {
          return Card(
            color: theme.colorScheme.primary,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                (y - appState.current).toString(),
                style: style,
                semanticsLabel: (y - appState.current).toString(),
              ),
            ),
          );
        } else {
          return Card(
            color: theme.colorScheme.primary,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "-",
                style: style,
                semanticsLabel: "-",
              ),
            ),
          );
        }
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = Home();
        break;
      case 1:
        page = Favorites();
        break;
      default:
        throw UnimplementedError("Ops, este widget não existe");
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
          body: Row(
        children: [
          SafeArea(
              child: NavigationRail(
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            selectedIndex: selectedIndex,
            onDestinationSelected: (value) {
              setState(() {
                print("selected ${value}");
                selectedIndex = value;
              });
            },
            extended: constraints.maxWidth <= 300,
            destinations: [
              NavigationRailDestination(
                  icon: Icon(Icons.home), label: Text("home")),
              NavigationRailDestination(
                  icon: Icon(Icons.phone), label: Text("favs"))
            ],
          )),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: page,
            ),
          ),
        ],
      ));
    });
  }
}

class Favorites extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.lista.isEmpty) {
      return Center(
        child: Text("nenhum favorito cadastrado"),
      );
    }

    return Scaffold(
        backgroundColor: Color.fromARGB(255, 87, 120, 87),
        appBar: AppBar(
          title: const Text("Histórico"),
        ),
        body: Center(
          child: ListView(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                        "TMO ${appState.lista.length > 0 ? (appState.listaAll / appState.lista.length).toInt() : 0}"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text("${appState.lista.length} atendidas"),
                  ),
                ],
              ),
              for (var favorito in appState.lista)
                ListTile(
                    leading: Icon(Icons.phone),
                    title: Text(favorito.toString())),
            ],
          ),
        ));
  }
}
