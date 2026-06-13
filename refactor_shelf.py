import os
import json

with open('extracted_methods.json', 'r', encoding='utf-8') as f:
    methods = json.load(f)

# 1. skeleton_card.dart
skeleton_code = '''import 'package:flutter/material.dart';
import '../../../core/widgets/neobrutalist_card.dart';

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
''' + methods['skeleton_card'].replace('Widget _buildSkeletonCard(BuildContext context)', 'Widget build(BuildContext context)')
with open('lib/features/shelf/widgets/skeleton_card.dart', 'w', encoding='utf-8') as f:
    f.write(skeleton_code)

# 2. product_image.dart
product_image_code = '''import 'dart:io';
import 'package:flutter/material.dart';

''' + methods['product_image'].replace('_buildProductImage', 'buildProductImage')
with open('lib/features/shelf/widgets/product_image.dart', 'w', encoding='utf-8') as f:
    f.write(product_image_code)

# 3. product_card.dart
product_card_code = '''import 'package:flutter/material.dart';
import '../../../core/models/models.dart';
import '../../../core/widgets/neobrutalist_card.dart';
import '../shelf_viewmodel.dart';
import 'product_image.dart';
import 'product_details_sheet.dart';
import 'delete_confirmation_dialog.dart';

class ProductCard extends StatelessWidget {
  final ShelfItem item;
  final ShelfViewModel shelfVm;

  const ProductCard({super.key, required this.item, required this.shelfVm});

  @override
''' + methods['product_card'].replace('Widget _buildNeobrutalistProductCard(BuildContext context, ShelfItem item, ShelfViewModel shelfVm)', 'Widget build(BuildContext context)').replace('_buildProductImage', 'buildProductImage').replace('_showDeleteConfirmation', 'showDeleteConfirmation').replace('_showProductDetailsBottomSheet', 'showProductDetailsBottomSheet')
with open('lib/features/shelf/widgets/product_card.dart', 'w', encoding='utf-8') as f:
    f.write(product_card_code)

# 4. delete_confirmation_dialog.dart
delete_code = '''import 'package:flutter/material.dart';
import '../../../core/models/models.dart';
import '../shelf_viewmodel.dart';

''' + methods['delete_confirmation_dialog'].replace('_showDeleteConfirmation', 'showDeleteConfirmation')
with open('lib/features/shelf/widgets/delete_confirmation_dialog.dart', 'w', encoding='utf-8') as f:
    f.write(delete_code)

# 5. edit_product_dialog.dart
edit_code = '''import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/models/models.dart';
import '../shelf_viewmodel.dart';
import 'product_image.dart';

''' + methods['edit_product_dialog'].replace('_showEditProductDialog', 'showEditProductDialog').replace('_buildProductImage', 'buildProductImage')
with open('lib/features/shelf/widgets/edit_product_dialog.dart', 'w', encoding='utf-8') as f:
    f.write(edit_code)

# 6. product_details_sheet.dart
details_code = '''import 'package:flutter/material.dart';
import '../../../core/models/models.dart';
import '../shelf_viewmodel.dart';
import 'product_image.dart';
import 'edit_product_dialog.dart';
import 'delete_confirmation_dialog.dart';

''' + methods['detail_metric'].replace('_buildDetailMetric', 'buildDetailMetric') + '\n\n' + methods['product_details_sheet'].replace('_showProductDetailsBottomSheet', 'showProductDetailsBottomSheet').replace('_buildDetailMetric', 'buildDetailMetric').replace('_buildProductImage', 'buildProductImage').replace('_showEditProductDialog', 'showEditProductDialog').replace('_showDeleteConfirmation', 'showDeleteConfirmation')
with open('lib/features/shelf/widgets/product_details_sheet.dart', 'w', encoding='utf-8') as f:
    f.write(details_code)

# 7. filter_dialog.dart
filter_code = '''import 'package:flutter/material.dart';
import '../shelf_viewmodel.dart';

''' + methods['filter_dialog'].replace('_showFilterDialog', 'showFilterDialog')
with open('lib/features/shelf/widgets/filter_dialog.dart', 'w', encoding='utf-8') as f:
    f.write(filter_code)

# 8. add_product_dialog.dart
add_code = '''import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../shelf_viewmodel.dart';

''' + methods['add_product_dialog'].replace('_showAddProductDialog', 'showAddProductDialog')
with open('lib/features/shelf/widgets/add_product_dialog.dart', 'w', encoding='utf-8') as f:
    f.write(add_code)

# Replace in shelf_screen.dart
with open('lib/features/shelf/shelf_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace('_buildSkeletonCard(context)', 'SkeletonCard()')
content = content.replace('_buildNeobrutalistProductCard(context, item, shelfVm)', 'ProductCard(item: item, shelfVm: shelfVm)')
content = content.replace('_showFilterDialog(context, shelfVm)', 'showFilterDialog(context, shelfVm)')
content = content.replace('_showAddProductDialog(context, authVm.userId, shelfVm)', 'showAddProductDialog(context, authVm.userId, shelfVm)')

# Remove methods
def remove_method(content, start_str):
    idx = content.find(start_str)
    if idx == -1: return content
    start_idx = content.rfind('\n', 0, idx) + 1
    brace_count = 0
    in_block = False
    in_string = False
    string_char = ''
    escape = False
    end_idx = -1
    for i in range(idx, len(content)):
        c = content[i]
        if escape: escape = False; continue
        if c == '\\': escape = True; continue
        if c in ("'", '"'):
            if not in_string: in_string = True; string_char = c
            elif c == string_char: in_string = False
            continue
        if not in_string:
            if c == '{': brace_count += 1; in_block = True
            elif c == '}':
                brace_count -= 1
                if in_block and brace_count == 0: end_idx = i + 1; break
    if end_idx != -1:
        return content[:start_idx] + content[end_idx:]
    return content

for start in methods.values():
    content = remove_method(content, start)

imports = '''import 'widgets/skeleton_card.dart';
import 'widgets/product_card.dart';
import 'widgets/filter_dialog.dart';
import 'widgets/add_product_dialog.dart';
'''
last_import_idx = content.rfind('import ')
end_last_import = content.find('\n', last_import_idx)
content = content[:end_last_import+1] + imports + content[end_last_import+1:]

with open('lib/features/shelf/shelf_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)

