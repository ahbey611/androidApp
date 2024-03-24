import 'package:flutter/material.dart';

PreferredSizeWidget getAppBar(bool backButton, String title,
    {List<Widget>? actions}) {
  const Color color = Color.fromARGB(255, 250, 209, 252);

  return AppBar(
    automaticallyImplyLeading: backButton,
    title: Text(
      title,
      style: const TextStyle(
        fontFamily: 'inter',
        fontSize: 21,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    ),
    flexibleSpace: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color,
            Color.fromARGB(255, 255, 255, 255),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(
          bottom: BorderSide(
            color: Color.fromRGBO(169, 171, 179, 1),
            width: 1,
          ),
        ),
      ),
    ),
    actions: actions,
  );
}
