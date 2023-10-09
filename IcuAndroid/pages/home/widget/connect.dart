import 'package:flutter/material.dart';

//class Connect extends StatelessWidget {
//const Connect({super.key});

//@override
//Widget build(BuildContext context) {
// return Column(
// children: [
// Padding(
//padding: const EdgeInsets.symmetric(
// vertical: 20,
//horizontal: 30,
// ),
// child: Row(
// children: [
// Text(
//"CONNET",
// style: Theme.of(context).textTheme.displayLarge,
// ),
// IconButton(
// onPressed: () {},
// icon: Icon(
//  Icons.connect_without_contact_outlined,
// size: 35,
//color: Colors.blue,
//))
//   ],
// ),
// ),
//],
// );
// }
//}
class Connect extends StatelessWidget {
  final bool isConnected;
  final VoidCallback onConnect;

  Connect({required this.isConnected, required this.onConnect});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isConnected ? null : onConnect,
      child: Text(isConnected ? 'CONNECTED' : 'NOT CONNECTED'),
    );
  }
}
