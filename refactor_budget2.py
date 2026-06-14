import os

with open('lib/features/budget/budget_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Replace Allocation Card
alloc_idx = content.find('// Allocation Card')
end_alloc_idx = content.find('// Spending History Card')
if alloc_idx != -1 and end_alloc_idx != -1:
    content = content[:alloc_idx] + '''// Allocation Card
              AllocationCard(isDark: isDark),
              const SizedBox(height: 24),

              ''' + content[end_alloc_idx:]

def extract_between(content, start_idx, start_str):
    idx = content.find(start_str, start_idx)
    if idx == -1: return None, idx
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
            if c == '(': brace_count += 1; in_block = True
            elif c == ')':
                brace_count -= 1
                if in_block and brace_count == 0: end_idx = i + 1; break
    if end_idx != -1:
        return content[idx:end_idx], end_idx
    return None, idx

calc_idx = content.find('// Cost-Per-Apply Card')
if calc_idx != -1:
    calc_str, end_idx = extract_between(content, calc_idx, 'NeobrutalistCard(')
    if calc_str:
        replacement = '''CalculatorCard(
                isDark: isDark,
                selectedProductId: _selectedProductId,
                priceController: _priceController,
                usesController: _usesController,
                onProductChanged: (val) {
                  if (val != null) {
                    setState(() { _selectedProductId = val; });
                    if (val != 'custom') {
                      final prod = budgetVm.shelfItems.firstWhere((x) => x.id == val);
                      _syncControllersWithProduct(prod, budgetVm);
                    }
                  }
                },
                onPriceChanged: (val) {
                  setState(() { _selectedProductId = 'custom'; });
                  final parsed = double.tryParse(val);
                  if (parsed != null) budgetVm.updateCalculator(price: parsed);
                },
                onUsesChanged: (val) {
                  setState(() { _selectedProductId = 'custom'; });
                  final parsed = int.tryParse(val);
                  if (parsed != null) budgetVm.updateCalculator(uses: parsed);
                },
              )'''
        content = content[:calc_idx] + '// Cost-Per-Apply Card\n              ' + replacement + content[end_idx:]

# Remove ConcentricRingsPainter class entirely
painter_idx = content.find('// Custom concentric rings painter representing budget allocation categories')
if painter_idx != -1:
    content = content[:painter_idx]

imports = '''import 'widgets/allocation_card.dart';
import 'widgets/calculator_card.dart';
import 'widgets/concentric_rings_painter.dart';
'''
last_import_idx = content.rfind('import ')
end_last_import = content.find('\n', last_import_idx)
content = content[:end_last_import+1] + imports + content[end_last_import+1:]

# Make sure trailing brace is preserved if we stripped too much
if not content.strip().endswith('}'):
    content += '\n}\n'

with open('lib/features/budget/budget_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
