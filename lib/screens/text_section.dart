import 'package:flutter/material.dart';

class TextSection extends StatelessWidget{
  final Text _text;
  TextSection(this._text);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.red,

      ),
      child: _text,
    );
  }
}