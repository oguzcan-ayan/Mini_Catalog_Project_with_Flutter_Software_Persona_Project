import 'dart:convert';

import 'package:mini_catalog_project/models/product_model.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const baseUrl = 'https://fakestoreapi.com/products';

  Future<List<ProductsModel>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ProductsModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  Future<ProductsModel> fetchProductById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$id'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ProductsModel.fromJson(data);
      } else {
        throw Exception('Failed to load product. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching product: $e');
    }
  }

  Future<List<ProductsModel>> fetchProductsByCategory(String category) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/category/$category'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ProductsModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products by category. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching products by category: $e');
    }
  }
}