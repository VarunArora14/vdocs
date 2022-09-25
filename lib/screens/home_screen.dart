import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:vdocs/common/widgets/loader.dart';
import 'package:vdocs/constants/colors.dart';
import 'package:vdocs/models/document_model.dart';
import 'package:vdocs/models/error_model.dart';
import 'package:vdocs/repository/auth_repository.dart';
import 'package:vdocs/repository/document_repo.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void signOut(WidgetRef ref) {
    ref.watch(authRepoProvider).signOut(); // call method to empty token
    ref.watch(userProvider.notifier).update((state) => null); // update userProvider to null
    // it checks on main of RouteMaster where we ref.watch userProvider and if it is null it will
    // call the loggedOutRoute
  }

  /// create document using user token and route to that url else show snackbar
  void createDocument(BuildContext context, WidgetRef ref) async {
    // async as we use the createDocument method which is async
    String token = ref.read(userProvider)!.token; //token from userProvider, cannot be null as we on home screen
    final navigator = Routemaster.of(context);
    final snackbar = ScaffoldMessenger.of(context); // to avoid putting between async and await block

    final errorModel = await ref.read(documentRepoProvider).createDocument(token); // call createDocument method

    if (errorModel.data != null) {
      // it has the new doc created
      navigator.push('/document/${errorModel.data.id}'); // id of document from DocumentModel
    } else {
      snackbar.showSnackBar(SnackBar(content: Text(errorModel.error.toString()))); // error from ErrorModel
      debugPrint('createDocument method invoked');
    }
  }

  /// go to the document screen based on card clicked
  void navigateToDocument(BuildContext context, String docId) {
    Routemaster.of(context).push('/document/$docId');
    // push instead of replace to get access to back button
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String token = ref.watch(userProvider)!.token; // token from userProvider, can't be null on home screen
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => createDocument(context, ref),
            icon: const Icon(
              Icons.add, //  add new document
              color: kBlackColor,
            ),
          ),
          IconButton(
            onPressed: () => signOut(ref),
            icon: const Icon(
              Icons.logout, // logout user
              color: kRedColor,
            ),
          )
        ],
      ),
      body: FutureBuilder<ErrorModel>(
        future: ref.watch(documentRepoProvider).getDocuments(token),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          }
          return Center(
            child: Container(
              margin: EdgeInsets.only(top: 20),
              width: 600,
              child: ListView.builder(
                itemCount: snapshot.data!.data == null
                    ? 0
                    : snapshot.data!.data.length, // snapshot data -> errorModel -> data -> list of documents
                itemBuilder: (BuildContext context, int index) {
                  // get particular documents
                  DocumentModel document = snapshot.data!.data[index];
                  // use inkwell for splash effect over each document
                  return InkWell(
                    onTap: () => navigateToDocument(context, document.id),
                    child: SizedBox(
                      height: 50,
                      child: Card(
                        child: Center(
                          child: Text(
                            document.title,
                            style: const TextStyle(fontSize: 17),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    ));
  }
}

// can use futureprovider to get data from api and use it in the build method instead of future builder