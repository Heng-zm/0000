import 'package:flutter/material.dart';
import 'api_service.dart';

void main() {
  runApp(AdminDashboard());
}

class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AdminHomePage(),
    );
  }
}

class AdminHomePage extends StatefulWidget {
  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final ApiService apiService =
      ApiService(username: 'admin', password: 'password123');
  late Future<List<dynamic>> menuFuture;
  late Future<List<dynamic>> ordersFuture;
  late Future<List<dynamic>> feedbackFuture;

  @override
  void initState() {
    super.initState();
    menuFuture = apiService.getMenu();
    ordersFuture = apiService.getOrders();
    feedbackFuture = apiService.getFeedback();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Dashboard')),
      body: ListView(
        children: [
          _buildSection('Menu Management', menuFuture),
          _buildSection('Order Management', ordersFuture),
          _buildSection('Feedback Management', feedbackFuture),
        ],
      ),
    );
  }

  void _showAddFoodItemDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Food Item'),
          content: Column(
            children: [
              TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Food Name')),
              TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description')),
              TextField(
                  controller: priceController,
                  decoration: InputDecoration(labelText: 'Price')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final foodItem = {
                  'name': nameController.text,
                  'description': descriptionController.text,
                  'price': double.parse(priceController.text),
                };
                await apiService.addFoodItem(foodItem);
                setState(() {
                  menuFuture = apiService.getMenu(); // Refresh menu
                });
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSection(String title, Future<List<dynamic>> future) {
    return FutureBuilder<List<dynamic>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('$title: No data available');
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(title,
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  var item = snapshot.data![index];
                  return ListTile(
                    title: Text(item['name'] ?? 'No Name'),
                    subtitle: Text(item['description'] ?? 'No Description'),
                  );
                },
              ),
            ],
          );
        }
      },
    );
  }
}
