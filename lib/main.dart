import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:vdocs/models/error_model.dart';
import 'package:vdocs/router.dart';
import 'package:vdocs/screens/home_screen.dart';
import 'package:vdocs/screens/login_screen.dart';
import 'package:vdocs/repository/auth_repository.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

// ProviderScope must be at root of this widget tree if we want to use riverpod in our app
// when using provider, we have to wrap with storehouse widget or a provider which stores info of all other
// providers, here we simply wrap myApp with widget named ProviderScope

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  ErrorModel? errorModel; // null till we are fetching the data
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserData(); // add this to get data at start
  }

  void getUserData() async {
    // for passing  data here, we use ref by making this ConsumerStatefulWidget
    errorModel = await ref.read(authRepoProvider).getuserData();
    if (errorModel != null && errorModel!.error == null) {
      // if errorModel not null and error is null means there is data
      ref.watch(userProvider.notifier).update((state) => errorModel!.data);
      // update the userProvider state with the data of UserModel sent
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Vdocs',
      theme: ThemeData(primarySwatch: Colors.blue),
      routerDelegate: RoutemasterDelegate(routesBuilder: (context) {
        final user = ref.watch(userProvider); // watch the userProvider state here
        // debugPrint(user.email ?? 'nil');
        if (user != null && user.token.isNotEmpty) {
          // if user is not null and token is not empty, means user is logged in
          return loggedinRoute;
        } else {
          return loggedOutRoute;
        }
      }),
      routeInformationParser: RoutemasterParser(), // initialize the parser with routedelegate
    );
  }
}

// todo: deployed on localhost:3000 on https://console.cloud.google.com/
// see the the video of gdocs clone if any problem with running app on cloud occurs
