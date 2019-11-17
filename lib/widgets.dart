import 'package:flutter/material.dart';


class EnergyButton extends StatelessWidget {

  final String name;
  final onPressed;

  EnergyButton(this.name, this.onPressed);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FlatButton(
        color: Colors.red,
        onPressed: onPressed,
        child: Text(name),
      ),
    );
  }

}