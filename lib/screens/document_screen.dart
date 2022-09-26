import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill; // otherwise text.dart interferes
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vdocs/common/widgets/loader.dart';
import 'package:vdocs/constants/colors.dart';
import 'package:vdocs/models/document_model.dart';
import 'package:vdocs/models/error_model.dart';
import 'package:vdocs/repository/auth_repository.dart';
import 'package:vdocs/repository/document_repo.dart';
import 'package:vdocs/repository/socket_repo.dart';

class DocumentScreen extends ConsumerStatefulWidget {
  final String id; // unique for each document
  const DocumentScreen({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends ConsumerState<DocumentScreen> {
  TextEditingController titleController = TextEditingController(text: 'Untitled Document');
  quill.QuillController? quillController; // null with initstate assign
  ErrorModel? errorModel; // for title and data of document
  SocketRepo socketRepo = SocketRepo();
  // todo: make above items late

  @override
  void initState() {
    super.initState();
    socketRepo.joinRoom(widget.id); // join room having id as documentId, before fetch as we make socket calls
    fetchDocumentData(); // method to show all changes made to the document

    socketRepo.changeListener((data) {
      // data is a map having 2 properties 'delta' and 'row'
      // when we get data, we want to compose the data
      quillController?.compose(
        quill.Delta.fromJson(data['delta']), // delta is the change made to the document
        quillController?.selection ??
            const TextSelection.collapsed(offset: 0), // use selection if available, otherwise use collapsed offset
        quill.ChangeSource.REMOTE,
      );
      // it calls notifyListeners() which calls build() again so no need setstate here
    });
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
  }

  /// client method to get changed data
  void fetchDocumentData() async {
    final token = ref.read(userProvider)!.token;
    errorModel = await ref.read(documentRepoProvider).getDocumentById(token, widget.id);
    // debugPrint(errorModel!.data!.title.toString());
    // check if erroModel data is not null and based on that show change in the document
    if (errorModel!.data != null) {
      // debugPrint(errorModel!.data!.title.toString());
      titleController.text = (errorModel!.data as DocumentModel).title;
      quillController = quill.QuillController(
        document: errorModel!.data.content.isEmpty // if content empty then basic quill document
            ? quill.Document() // otherwise use fromDelta method to convert json to quill document
            : quill.Document.fromDelta(quill.Delta.fromJson(errorModel!.data.content)),
        selection: const TextSelection.collapsed(offset: 0),
      );
      setState(() {});
    }

    // here we can listen to changes made in document
    quillController!.document.changes.listen((event) {
      if (event.item3 == quill.ChangeSource.LOCAL) {
        // only we have to send it to the server
        Map<String, dynamic> map = {
          'delta': event.item2.toJson(), // pass the changes not full document(item1)
          'room': widget.id // documentId same as roomId
        };
        // call method for changes
        socketRepo.typing(map);
      }
    });

    // event of type Tuple(Delta, Delta, ChangeSource). 1st delta is entire content of the document
    // 2nd delta is to reflect changes made from previous part
    // 3rd is changeSource which is local or remote. If local then data sent like http request, if remote then socket
    // and through above compose() method we can get the changes made to the document
  }

  /// client method to change title and call repo method to send data to server
  void updateTitle(WidgetRef ref, String title) async {
    final token = ref.read(userProvider)!.token;
    ref.watch(documentRepoProvider).updateTitle(token: token, id: widget.id, title: title);
    // title when user changes the field, token from userProvider and id passed in constructor

    // earlier this part of code has errorModel!.data if-else which made it run weird
  }

  @override
  Widget build(BuildContext context) {
    if (quillController == null) {
      return const Scaffold(
        body: Loader(),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: kBlueColor),
                onPressed: () {},
                icon: const Icon(
                  Icons.lock,
                  color: kWhiteColor,
                  size: 16,
                ),
                label: const Text(
                  'Share',
                  style: TextStyle(color: kWhiteColor),
                )),
          )
        ],
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Row(
            children: [
              Image.asset(
                'assets/images/docs_logo.png',
                height: 40,
              ),
              const SizedBox(
                width: 10,
              ),
              // textfield tries to take full space so make it constrained
              SizedBox(
                width: 180,
                child: TextField(
                  controller: titleController,
                  onSubmitted: (value) => updateTitle(ref, value),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(left: 10),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: kBlueColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // show a border below by creating own PreferredSizeWidget with bottom:
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            decoration: BoxDecoration(border: Border.all(color: kGreyColor, width: 0.1)),
          ),
          // height of the border, keep width same as max
        ),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            quill.QuillToolbar.basic(controller: quillController!), // assure it cannot be null
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: SizedBox(
                width: 750,
                child: Card(
                  elevation: 5,
                  color: kWhiteColor,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: quill.QuillEditor.basic(
                      controller: quillController!,
                      readOnly: false, // true for view only mode
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
