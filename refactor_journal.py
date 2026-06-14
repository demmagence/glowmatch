import os

with open('lib/features/journal/journal_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

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

# The actual strings in Dart
photo_card_a = '''_buildPhotoCard(
                context: context,
                entry: a,
              )'''
replacement_a = '''PhotoCard(entry: a, isSelected: _selectedEntryIds.contains(a.id), isCompareMode: _isCompareMode, onToggleSelection: () { setState(() { if (_selectedEntryIds.contains(a.id)) { _selectedEntryIds.remove(a.id); } else { if (_selectedEntryIds.length < 2) { _selectedEntryIds.add(a.id); } else { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You can only select up to 2 entries for comparison.'), duration: Duration(milliseconds: 1500),)); } } }); },)'''

photo_card_b = '''_buildPhotoCard(
                      context: context,
                      entry: b,
                    )'''
replacement_b = '''PhotoCard(entry: b, isSelected: _selectedEntryIds.contains(b.id), isCompareMode: _isCompareMode, onToggleSelection: () { setState(() { if (_selectedEntryIds.contains(b.id)) { _selectedEntryIds.remove(b.id); } else { if (_selectedEntryIds.length < 2) { _selectedEntryIds.add(b.id); } else { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You can only select up to 2 entries for comparison.'), duration: Duration(milliseconds: 1500),)); } } }); },)'''

content = content.replace(photo_card_a, replacement_a)
content = content.replace(photo_card_b, replacement_b)
content = content.replace('_buildEmptySlot(context, userId, vm)', 'EmptySlot(userId: userId, vm: vm, onShowPhotoSourceSheet: (ctx, uid, v) => showPhotoSourceSheet(ctx, uid, v, _doUpload))')
content = content.replace('_showPhotoSourceSheet(context, authVm.userId, journalVm)', 'showPhotoSourceSheet(context, authVm.userId, journalVm, _doUpload)')

content = remove_method(content, '_buildPhotoCard(')
content = remove_method(content, '_buildEmptySlot(')
content = remove_method(content, '_photoPlaceholder(')
content = remove_method(content, 'void _showPhotoSourceSheet(')
content = remove_method(content, 'Widget _sourceOption(')

imports = '''import 'widgets/photo_card.dart';
import 'widgets/empty_slot.dart';
import 'widgets/photo_source_sheet.dart';
'''
last_import_idx = content.rfind('import ')
end_last_import = content.find('\n', last_import_idx)
content = content[:end_last_import+1] + imports + content[end_last_import+1:]

with open('lib/features/journal/journal_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
