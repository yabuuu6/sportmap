import 'package:flutter/material.dart';

class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onLogout;
  final VoidCallback? onAccount;

  const TopAppBar({
    Key? key,
    required this.title,
    this.onLogout,
    this.onAccount,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.purple,
      elevation: 0,
      centerTitle: true,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(Icons.person, color: Colors.purple),
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.menu),
          onSelected: (value) {
            if (value == 'logout' && onLogout != null) {
              onLogout!();
            } else if (value == 'account' && onAccount != null) {
              onAccount!();
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'account',
              child: Text('Akun'),
            ),
            const PopupMenuItem<String>(
              value: 'logout',
              child: Text('Keluar'),
            ),
          ],
        ),
      ],
    );
  }
}
