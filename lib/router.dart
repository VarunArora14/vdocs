import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
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
  //todo: add route for documents
});
