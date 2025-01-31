import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String apiUrl = "http://127.0.0.1:8000/menu"; // FastAPI URL

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Admin Dashboard',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AdminDashboard(),
    );
  }
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<dynamic> menuItems = [];

  @override
  void initState() {
    super.initState();
    fetchMenu();
  }

  Future<void> fetchMenu() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      setState(() {
        menuItems = json.decode(response.body);
      });
    }
  }

  Future<void> addFood(String name, double price, String description) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: json
          .encode({"name": name, "price": price, "description": description}),
    );

    if (response.statusCode == 200) {
      fetchMenu();
    }
  }

  Future<void> updateFood(
      int id, String name, double price, String description) async {
    final response = await http.put(
      Uri.parse("$apiUrl/$id"),
      headers: {"Content-Type": "application/json"},
      body: json
          .encode({"name": name, "price": price, "description": description}),
    );

    if (response.statusCode == 200) {
      fetchMenu();
    }
  }

  Future<void> deleteFood(int id) async {
    final response = await http.delete(Uri.parse("$apiUrl/$id"));
    if (response.statusCode == 200) {
      fetchMenu();
    }
  }

  void showFoodDialog(
      {int? id, String? name, double? price, String? description}) {
    TextEditingController nameController =
        TextEditingController(text: name ?? "");
    TextEditingController priceController =
        TextEditingController(text: price?.toString() ?? "");
    TextEditingController descriptionController =
        TextEditingController(text: description ?? "");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(id == null ? "Add Food Item" : "Edit Food Item"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Food Name")),
            TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Price")),
            TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Description")),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              String newName = nameController.text;
              double? newPrice = double.tryParse(priceController.text);
              String newDescription = descriptionController.text;

              if (newName.isNotEmpty &&
                  newPrice != null &&
                  newDescription.isNotEmpty) {
                if (id == null) {
                  addFood(newName, newPrice, newDescription);
                } else {
                  updateFood(id, newName, newPrice, newDescription);
                }
                Navigator.pop(context);
              }
            },
            child: Text(id == null ? "Add" : "Update"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),
      body: menuItems.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                var item = menuItems[index];
                return Card(
                  child: ListTile(
                    title: Text(item["name"]),
                    subtitle:
                        Text("\$${item["price"]} - ${item["description"]}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => showFoodDialog(
                            id: item["id"],
                            name: item["name"],
                            price: item["price"],
                            description: item["description"],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteFood(item["id"]),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showFoodDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
