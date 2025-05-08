import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../placement/placement_page.dart';
import '../entry/entry_page.dart';
import '../picking/picking_page.dart';
import '../login/login_page.dart';

class MenuItem {
  final String title;
  final String description;
  final IconData icon;
  final Widget page;

  MenuItem(this.title, this.description, this.icon, this.page);
}

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final List<MenuItem> menuItems = [
    MenuItem(
      'Entrada',
      'Registro de ingreso de productos',
      Icons.input,
      EntryPage(),
    ),
    MenuItem(
      'Colocación',
      'Ubicación y stock de productos',
      Icons.location_on,
      PlacementPage(),
    ),
    MenuItem(
      'Recogida',
      'Preparación de pedidos para salida',
      Icons.output,
      PlacementPage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selk'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Simplificado para pruebas
              Navigator.of(
                context,
              ).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Text(
            'Inicio',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return _buildMenuItem(context, item);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              'Versión 1.0.0',
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Cerrar Sesión',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            // Cerrar sesión simplificado
            Navigator.of(
              context,
            ).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
          }
        },
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, MenuItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        child: InkWell(
          borderRadius: BorderRadius.circular(40),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => item.page),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Card(
                  color: AppColors.primaryLight,
                  shape: CircleBorder(),
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(item.icon, color: Colors.white, size: 30),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      Text(
                        item.description,
                        style: TextStyle(fontSize: 16, fontFamily: 'Roboto'),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.keyboard_arrow_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
