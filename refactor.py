import sys
import os
import re

def extract_block(content, start_str, is_class=False):
    if is_class:
        match = re.search(r'class\s+' + start_str + r'\b.*?\{', content, re.DOTALL)
        if not match:
            return None, content
        idx = match.start()
    else:
        # For functions like Widget _buildSomething()
        match = re.search(r'(?:Widget|void|Future<void>)\s+' + start_str + r'\s*\(.*?\)\s*(?:async\s*)?\{', content, re.DOTALL)
        if not match:
            return None, content
        idx = match.start()
        
    brace_count = 0
    in_block = False
    in_string = False
    string_char = ''
    escape = False
    
    start_idx = idx
    end_idx = -1
    
    for i in range(idx, len(content)):
        c = content[i]
        
        if escape:
            escape = False
            continue
            
        if c == '\\':
            escape = True
            continue
            
        if c in ('\'', '\"'):
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
        extracted = content[start_idx:end_idx]
        new_content = content[:start_idx] + content[end_idx:]
        return extracted, new_content
    return None, content

def refactor_file(file_path, extractions, out_dir):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
        
    os.makedirs(out_dir, exist_ok=True)
    
    for ext_name, is_class, out_file in extractions:
        extracted, content = extract_block(content, ext_name, is_class)
        if extracted:
            print(f"Extracted {ext_name} to {out_file}")
            with open(os.path.join(out_dir, out_file), 'w', encoding='utf-8') as f:
                f.write(extracted)
        else:
            print(f"Could not find {ext_name} in {file_path}")
            
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)

print("Starting refactor...")

# Task 1: Shelf Screen
shelf_extractions = [
    ('_buildNeobrutalistProductCard', False, 'product_card.dart'),
    ('_showProductDetailsBottomSheet', False, 'product_details_sheet.dart'),
    ('_showAddProductDialog', False, 'add_product_dialog.dart'),
    ('_showEditProductDialog', False, 'edit_product_dialog.dart'),
    ('_showFilterDialog', False, 'filter_dialog.dart'),
    ('_showDeleteConfirmation', False, 'delete_confirmation_dialog.dart'),
    ('_buildSkeletonCard', False, 'skeleton_card.dart'),
]
refactor_file('lib/features/shelf/shelf_screen.dart', shelf_extractions, 'lib/features/shelf/widgets/')

# Task 2: Journal Screen
journal_extractions = [
    ('_buildPhotoCard', False, 'photo_card.dart'),
    ('_buildEmptySlot', False, 'empty_slot.dart'),
    ('_showPhotoSourceSheet', False, 'photo_source_sheet.dart'),
    ('_sourceOption', False, 'source_option.dart'),
]
refactor_file('lib/features/journal/journal_screen.dart', journal_extractions, 'lib/features/journal/widgets/')

# Task 3: Budget Screen
budget_extractions = [
    ('ConcentricRingsPainter', True, 'concentric_rings_painter.dart'),
    ('_buildAllocationCard', False, 'allocation_card.dart'), # Assuming it's _buildAllocationCard
    ('_buildCalculatorCard', False, 'calculator_card.dart'), # Assuming it's _buildCalculatorCard
]
# Wait, let's check the exact names in budget_screen before doing it. Let's do budget later if names mismatch.
