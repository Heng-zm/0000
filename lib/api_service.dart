import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

// Base URL for your FastAPI backend
const String baseUrl = 'http://127.0.0.1:8000';

// API Service class for interacting with FastAPI backend
class ApiService {
  final String username;
  final String password;

  ApiService({required this.username, required this.password});

  // Helper function for making GET requests with basic authentication
  Future<List<dynamic>> _getRequest(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Authorization':
            'Basic ' + base64Encode(utf8.encode('$username:$password')),
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  // Get all menu items
  Future<List<dynamic>> getMenu() async {
    return await _getRequest('/menu');
  }

  // Get all orders
  Future<List<dynamic>> getOrders() async {
    return await _getRequest('/orders');
  }

  // Get all feedback
  Future<List<dynamic>> getFeedback() async {
    return await _getRequest('/feedback');
  }

  // Add a new food item to the menu (POST request)
  Future<void> addFoodItem(Map<String, dynamic> foodItem) async {
    final response = await http.post(
      Uri.parse('$baseUrl/menu'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Basic ' + base64Encode(utf8.encode('$username:$password')),
      },
      body: json.encode(foodItem),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add food item');
    }
  }
}
