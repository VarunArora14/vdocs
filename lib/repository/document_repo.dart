import 'dart:convert';
import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:vdocs/constants/constants.dart';
import 'package:vdocs/models/document_model.dart';
import 'package:vdocs/models/error_model.dart';

final documentRepoProvider = Provider(
  (ref) => DocumentRepo(
    client: Client(), // creates instance of client and we store that in the documentRepoProvider
  ),
);

class DocumentRepo {
  final Client _client;
  DocumentRepo({
    required Client client,
  }) : _client = client;

  /// repo method to create a new document for user based on their token
  Future<ErrorModel> createDocument(String token) async {
    ErrorModel error = ErrorModel(
      error: 'Document instance has not been created',
      data: null,
    );
    try {
      var res = await _client.post(
        Uri.parse('$host/doc/create'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
        body: jsonEncode(
          {
            // send encoded object and not just map
            'createdAt': DateTime.now().millisecondsSinceEpoch,
          },
        ),
      );
      switch (res.statusCode) {
        case 200:
          error = ErrorModel(error: null, data: DocumentModel.fromJson(res.body)); // get from document.js
          break;
        default: // if any other status code
          error = ErrorModel(error: res.body, data: null);
          debugPrint(res.body.toString());
          break;
      }
    } catch (e) {
      error = ErrorModel(error: e.toString(), data: null);
      debugPrint('catch block of document repo create document');
    }
    return error;
  }

  /// repo method to get list of documents of given user based on their token
  Future<ErrorModel> getDocuments(String token) async {
    ErrorModel error = ErrorModel(
      error: 'Document instance has not been created',
      data: null,
    );
    try {
      var res = await _client.get(
        Uri.parse('$host/docs/me'), // make sure it matches with document.js
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );
      switch (res.statusCode) {
        case 200:
          List<DocumentModel> docs = [];
          // list of documents from response which returns all docs of current user
          final decodedBody = jsonDecode(res.body);
          for (int i = 0; i < decodedBody.length; i++) {
            String docString = jsonEncode(decodedBody[i]);
            DocumentModel currDoc = DocumentModel.fromJson(docString);
            docs.add(currDoc);
          }
          error = ErrorModel(error: null, data: docs); // save the docs in the error model
          break;
        default: // if any other status code
          error = ErrorModel(error: res.body, data: null);
          break;
      }
    } catch (e) {
      error = ErrorModel(error: e.toString(), data: null);
      debugPrint(e.toString());
      debugPrint('catch block of document repo create document');
    }
    return error;
  }

  /// repo method to update the title of the document
  void updateTitle({required String token, required String id, required String title}) async {
    await _client.post(
      Uri.parse('$host/doc/title'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': token,
      },
      body: jsonEncode(
        {
          'id': id,
          'title': title,
        },
      ),
    );
  }

  /// repo method to update the content of the document
  Future<ErrorModel> getDocumentById(String token, String id) async {
    ErrorModel error = ErrorModel(
      error: 'Document instance has not been created',
      data: null,
    );
    try {
      var res = await _client.get(
        Uri.parse('$host/doc/$id'), // make sure it matches with document.js
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );
      switch (res.statusCode) {
        case 200:
          error =
              ErrorModel(error: null, data: DocumentModel.fromJson(res.body)); // save the docs in the error model
          debugPrint(res.body);
          break;
        default: // if any other status code
          throw 'This Document does not exist, create a new one'; // throws error to catch block
      }
    } catch (e) {
      error = ErrorModel(error: e.toString(), data: null);
      debugPrint(e.toString());
      debugPrint('catch block of document repo create document');
    }
    return error;
  }
}
