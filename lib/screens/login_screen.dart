import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:vdocs/constants/colors.dart';
import 'package:vdocs/repository/auth_repository.dart';
import 'package:vdocs/screens/home_screen.dart';

// make it consumer so we can consume it's data and changes using provider. Provider interacts with providers
// and WidgetRef allows us to interact with widgets
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  void signInWithGoogle(BuildContext context, WidgetRef ref) async {
    final sMessenger = ScaffoldMessenger.of(context); // defining context before await removes warning
    final navigator = Routemaster.of(context);
    // outside the build we can use read method to read the provider as it does it less number of times
    // and it is more efficient but prefer watch() when you have to read more than once
    final errorModel = await ref.read(authRepoProvider).signInWithGoogle();
    if (errorModel.error == null) {
      // no error so add the data to the userProvider, use .notifier to access the stateNotifier class
      ref.watch(userProvider.notifier).update((state) => errorModel.data);
      // pass this data is no error and update the userProvider
      navigator.replace('/'); // simply pass the route name, replace works like pushReplacement
    } else {
      sMessenger.showSnackBar(SnackBar(content: Text(errorModel.error!)));
      debugPrint('signInWithGoogle method invoked');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // use watch() not read() in build of provider, check docs for more info

    return SafeArea(
        child: Scaffold(
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () => signInWithGoogle(context, ref),
          icon: Image.asset(
            'assets/images/google_logo.png',
            height: 20,
            width: 20,
          ),
          label: Text(
            'Sign in with Google',
            style: TextStyle(color: kBlackColor),
          ),
          style: ElevatedButton.styleFrom(backgroundColor: kWhiteColor, minimumSize: Size(150, 50)),
        ),
      ),
    ));
  }
}
