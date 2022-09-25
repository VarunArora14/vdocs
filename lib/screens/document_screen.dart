import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill; // otherwise text.dart interferes
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vdocs/constants/colors.dart';

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
  quill.QuillController quillController = quill.QuillController.basic();
  // todo: make above items late
  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      body: Column(
        children: [
          quill.QuillToolbar.basic(controller: quillController),
          Expanded(
            child: SizedBox(
              width: 750,
              child: quill.QuillEditor.basic(
                controller: quillController,
                readOnly: false, // true for view only mode
              ),
            ),
          )
        ],
      ),
    );
  }
}
