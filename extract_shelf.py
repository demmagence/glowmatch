import os

with open('lib/features/shelf/shelf_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

def get_method(content, start_str):
    idx = content.find(start_str)
    if idx == -1: return None
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
        return content[start_idx:end_idx]
    return None

methods = {
    'skeleton_card': 'Widget _buildSkeletonCard',
    'product_image': 'Widget _buildProductImage',
    'product_card': 'Widget _buildNeobrutalistProductCard',
    'product_details_sheet': 'void _showProductDetailsBottomSheet',
    'delete_confirmation_dialog': 'void _showDeleteConfirmation',
    'filter_dialog': 'void _showFilterDialog',
    'add_product_dialog': 'void _showAddProductDialog',
    'edit_product_dialog': 'void _showEditProductDialog',
    'detail_metric': 'Widget _buildDetailMetric',
}

import json
results = {}
for name, start in methods.items():
    code = get_method(content, start)
    if code:
        results[name] = code

with open('extracted_methods.json', 'w', encoding='utf-8') as f:
    json.dump(results, f, indent=2)
