import os
import re

def extract_block(content, start_str):
    idx = content.find(start_str)
    if idx == -1: return None, content
    
    brace_count = 0
    in_block = False
    in_string = False
    string_char = ''
    escape = False
    end_idx = -1
    
    for i in range(idx, len(content)):
        c = content[i]
        if escape:
            escape = False
            continue
        if c == '\\':
            escape = True
            continue
        if c in ("'", '"'):
            if not in_string:
                in_string = True
                string_char = c
            elif c == string_char:
                in_string = False
            continue
        if not in_string:
            if c == '{':
                brace_count += 1
                in_block = True
            elif c == '}':
                brace_count -= 1
                if in_block and brace_count == 0:
                    end_idx = i + 1
                    break
                    
    if end_idx != -1:
        extracted = content[idx:end_idx]
        new_content = content[:idx] + content[end_idx:]
        return extracted, new_content
    return None, content

def process_file(file_path, widgets_dir, extractions):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
        
    os.makedirs(widgets_dir, exist_ok=True)
    imports = set()
    
    for ext_name, is_class, out_file in extractions:
        search_str = f'class {ext_name}' if is_class else f'{ext_name}('
        if not is_class:
            idx = content.find(search_str)
            if idx != -1:
                start_idx = content.rfind('\n', 0, idx) + 1
                method_def = content[start_idx:idx+len(search_str)]
                extracted, content = extract_block(content, method_def)
                if extracted:
                    extracted = extracted.strip()
                    public_name = ext_name.lstrip('_')
                    extracted = extracted.replace(ext_name, public_name, 1)
                    header = "import 'package:flutter/material.dart';\nimport 'package:provider/provider.dart';\nimport 'package:image_picker/image_picker.dart';\nimport 'dart:io';\nimport '../../core/models/models.dart';\nimport '../shelf_viewmodel.dart';\nimport '../journal_viewmodel.dart';\nimport '../../core/widgets/neobrutalist_card.dart';\nimport '../../core/theme/app_theme.dart';\nimport 'package:intl/intl.dart';\nimport 'package:cached_network_image/cached_network_image.dart';\n\n"
                    with open(os.path.join(widgets_dir, out_file), 'w', encoding='utf-8') as f:
                        f.write(header + extracted + '\n')
                    content = content.replace(ext_name + '(', public_name + '(')
                    imports.add(f"import 'widgets/{out_file}';")
                    print(f'Extracted {ext_name}')
        else:
            search_str = f'class {ext_name}'
            idx = content.find(search_str)
            if idx != -1:
                extracted, content = extract_block(content, search_str)
                if extracted:
                    header = "import 'package:flutter/material.dart';\nimport 'dart:math';\nimport '../../core/models/models.dart';\nimport '../budget_viewmodel.dart';\n\n"
                    with open(os.path.join(widgets_dir, out_file), 'w', encoding='utf-8') as f:
                        f.write(header + extracted + '\n')
                    imports.add(f"import 'widgets/{out_file}';")
                    print(f'Extracted {ext_name}')

    if imports:
        last_import = content.rfind('import ')
        if last_import != -1:
            end_of_import = content.find('\n', last_import)
            content = content[:end_of_import+1] + '\n'.join(imports) + '\n' + content[end_of_import+1:]
        
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)

process_file('lib/features/shelf/shelf_screen.dart', 'lib/features/shelf/widgets', [
    ('_buildNeobrutalistProductCard', False, 'product_card.dart'),
    ('_showProductDetailsBottomSheet', False, 'product_details_sheet.dart'),
    ('_showAddProductDialog', False, 'add_product_dialog.dart'),
    ('_showEditProductDialog', False, 'edit_product_dialog.dart'),
    ('_showFilterDialog', False, 'filter_dialog.dart'),
    ('_showDeleteConfirmation', False, 'delete_confirmation_dialog.dart'),
    ('_buildSkeletonCard', False, 'skeleton_card.dart'),
])

process_file('lib/features/journal/journal_screen.dart', 'lib/features/journal/widgets', [
    ('_buildPhotoCard', False, 'photo_card.dart'),
    ('_buildEmptySlot', False, 'empty_slot.dart'),
    ('_showPhotoSourceSheet', False, 'photo_source_sheet.dart'),
    ('_sourceOption', False, 'source_option.dart'),
])

process_file('lib/features/budget/budget_screen.dart', 'lib/features/budget/widgets', [
    ('ConcentricRingsPainter', True, 'concentric_rings_painter.dart'),
])
