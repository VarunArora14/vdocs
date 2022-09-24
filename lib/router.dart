import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:vdocs/screens/document_screen.dart';
import 'package:vdocs/screens/home_screen.dart';
import 'package:vdocs/screens/login_screen.dart';
// It contains the routeMap required by RoutemasterDelegate

// possible routes user can go to when logged out
final loggedOutRoute = RouteMap(routes: {
  '/': (route) => const MaterialPage(child: LoginScreen()),
});

// routes user can go to when logged in
final loggedinRoute = RouteMap(routes: {
  '/': (route) => const MaterialPage(child: HomeScreen()), // at root show homescreen
  '/document/:id': (route) => MaterialPage(
        child: DocumentScreen(
          id: route.pathParameters['id'] ?? '', // id of document same as '.../:id'
        ),
      ),

  // :id is a placeholder for the id of the document and ':' is called slug
  // It is used here so we can have multiple id's and we can work on them
});
