import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../controllers/category_controller.dart';
import '../../data/models/category_model.dart';
import '../dashboard/components/header.dart';
import 'components/category_dialog.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryController>().fetchCategories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryController>(
      builder: (context, controller, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Header(),
              const SizedBox(height: defaultPadding),
              Row(
                children: [
                  Icon(Icons.category, color: primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Quản lý Danh mục Ngành nghề',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _showCategoryDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm mới'),
                  ),
                  const SizedBox(width: 8),
                  if (!controller.isLoading)
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Tải lại',
                      onPressed: controller.fetchCategories,
                    ),
                ],
              ),
              const SizedBox(height: defaultPadding),
              _buildContentCard(context, controller),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContentCard(BuildContext context, CategoryController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Danh sách ngành nghề',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              SizedBox(
                width: 280,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm ngành nghề...',
                    isDense: true,
                    prefixIcon: const Icon(Icons.search, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: controller.setSearchQuery,
                ),
              ),
            ],
          ),
          const SizedBox(height: defaultPadding),
          if (controller.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: CircularProgressIndicator(),
              ),
            )
          else if (controller.errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Column(
                  children: [
                    Icon(Icons.error_outline,
                        size: 48, color: Colors.red.shade300),
                    const SizedBox(height: 12),
                    Text('Lỗi: ${controller.errorMessage}'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: controller.fetchCategories,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            )
          else if (controller.categories.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: Text('Không có dữ liệu'),
              ),
            )
          else
            _buildTable(context, controller),
        ],
      ),
    );
  }

  Widget _buildTable(BuildContext context, CategoryController controller) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        showCheckboxColumn: false,
        columns: const [
          DataColumn(label: Text('Tên ngành nghề')),
          DataColumn(label: Text('Mô tả')),
          DataColumn(label: Text('Trạng thái')),
          DataColumn(label: Text('Thao tác')),
        ],
        rows: controller.categories.map((category) {
          return DataRow(
            onSelectChanged: (_) => _showCategoryDialog(context, category: category),
            cells: [
              DataCell(
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.grey.shade200,
                      child: const Icon(Icons.work, size: 16, color: Colors.grey),
                    ),
                    const SizedBox(width: 8),
                    Text(category.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              DataCell(
                SizedBox(
                  width: 300,
                  child: Text(
                    category.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: category.isActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    category.isActive ? 'Đang kích hoạt' : 'Đang ẩn',
                    style: TextStyle(
                      color: category.isActive ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              DataCell(
                Row(
                  children: [
                    TextButton(
                      onPressed: () => _showCategoryDialog(context, category: category),
                      child: const Text('Sửa'),
                    ),
                    TextButton(
                      onPressed: () => _toggleActive(context, controller, category),
                      child: Text(
                        category.isActive ? 'Ẩn' : 'Hiện',
                        style: TextStyle(color: category.isActive ? Colors.red : Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showCategoryDialog(BuildContext context, {CategoryModel? category}) {
    showDialog(
      context: context,
      builder: (_) => CategoryDialog(category: category),
    );
  }

  Future<void> _toggleActive(BuildContext context, CategoryController controller, CategoryModel category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(category.isActive ? 'Ẩn danh mục' : 'Hiện danh mục'),
        content: Text(category.isActive 
            ? 'Bạn có chắc chắn muốn ẩn danh mục "${category.name}"? Người dùng sẽ không thấy danh mục này.'
            : 'Bạn có muốn hiển thị lại danh mục "${category.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: category.isActive ? Colors.red : Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(category.isActive ? 'Ẩn' : 'Hiện'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final error = await controller.toggleCategoryActive(category.id, !category.isActive);
      if (context.mounted) {
        if (error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã cập nhật trạng thái danh mục'), backgroundColor: Colors.green),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: $error'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}
