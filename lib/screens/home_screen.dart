import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vdocs/constants/colors.dart';
import 'package:vdocs/repository/auth_repository.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void signOut(WidgetRef ref) {
    ref.watch(authRepoProvider).signOut(); // call method to empty token
    ref.watch(userProvider.notifier).update((state) => null); // update userProvider to null
    // it checks on main of RouteMaster where we ref.watch userProvider and if it is null it will
    // call the loggedOutRoute
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.add, //  add new document
              color: kBlackColor,
            ),
          ),
          IconButton(
            onPressed: () => signOut(ref),
            icon: Icon(
              Icons.logout, // logout user
              color: kRedColor,
            ),
          )
        ],
      ),
      body: Center(
        child: Text(ref.watch(userProvider)!.uid),
        // use the userProvider to get the user data and authProvider for auth related stuff
      ),
    ));
  }
}
