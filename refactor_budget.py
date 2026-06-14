import os

def extract_between(content, start_str, match_braces=True):
    idx = content.find(start_str)
    if idx == -1: return None, content, idx
    start_idx = idx
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
            elif c == '(': brace_count += 1; in_block = True
            elif c == ')':
                brace_count -= 1
                if in_block and brace_count == 0: end_idx = i + 1; break
    if end_idx != -1:
        return content[start_idx:end_idx], content[:start_idx] + content[end_idx:], start_idx
    return None, content, idx

def read_file(path):
    with open(path, 'r', encoding='utf-8') as f: return f.read()

def write_file(path, content):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w', encoding='utf-8') as f: f.write(content)

content = read_file('lib/features/budget/budget_screen.dart')

# Allocation Card
alloc_idx = content.find('// Allocation Card')
if alloc_idx != -1:
    neo_idx = content.find('NeobrutalistCard(', alloc_idx)
    alloc_code, new_content, _ = extract_between(content[neo_idx:], 'NeobrutalistCard(')
    if alloc_code:
        alloc_widget = f"""import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../budget_viewmodel.dart';
import '../../core/widgets/neobrutalist_card.dart';
import 'concentric_rings_painter.dart';

class AllocationCard extends StatelessWidget {{
  final bool isDark;
  const AllocationCard({{super.key, required this.isDark}});

  @override
  Widget build(BuildContext context) {{
    final budgetVm = Provider.of<BudgetViewModel>(context);
    final hasAllocations = budgetVm.allocations.isNotEmpty;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final borderColor = isDark ? Colors.white : Colors.black;
    return {alloc_code};
  }}
}}
"""
        write_file('lib/features/budget/widgets/allocation_card.dart', alloc_widget)
        # We replace the extracted part
        content = content[:neo_idx] + "AllocationCard(isDark: isDark)," + content[neo_idx+len(alloc_code):]

calc_idx = content.find('// Cost-Per-Apply Card')
if calc_idx != -1:
    neo_idx = content.find('NeobrutalistCard(', calc_idx)
    calc_code, new_content, _ = extract_between(content[neo_idx:], 'NeobrutalistCard(')
    if calc_code:
        calc_widget = f"""import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../budget_viewmodel.dart';
import '../../core/widgets/neobrutalist_card.dart';

class CalculatorCard extends StatelessWidget {{
  final bool isDark;
  final String selectedProductId;
  final TextEditingController priceController;
  final TextEditingController usesController;
  final Function(String) onProductChanged;
  final Function(String) onPriceChanged;
  final Function(String) onUsesChanged;

  const CalculatorCard({{
    super.key,
    required this.isDark,
    required this.selectedProductId,
    required this.priceController,
    required this.usesController,
    required this.onProductChanged,
    required this.onPriceChanged,
    required this.onUsesChanged,
  }});

  @override
  Widget build(BuildContext context) {{
    final budgetVm = Provider.of<BudgetViewModel>(context);
    final textColor = isDark ? Colors.white : Colors.black;
    final subtextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final borderColor = isDark ? Colors.white : Colors.black;
    String _selectedProductId = selectedProductId;
    TextEditingController _priceController = priceController;
    TextEditingController _usesController = usesController;
    // We modify setState to just call callbacks and we'll have to manually fix inside CalculatorCard later
    return {calc_code};
  }}
}}
"""
        write_file('lib/features/budget/widgets/calculator_card.dart', calc_widget)
        content = content[:neo_idx] + """CalculatorCard(
                isDark: isDark,
                selectedProductId: _selectedProductId,
                priceController: _priceController,
                usesController: _usesController,
                onProductChanged: (val) {
                  setState(() { _selectedProductId = val; });
                  if (val != 'custom') {
                    final prod = budgetVm.shelfItems.firstWhere((x) => x.id == val);
                    _syncControllersWithProduct(prod, budgetVm);
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
              ),""" + content[neo_idx+len(calc_code):]

# Add imports
imports = ["import 'widgets/allocation_card.dart';", "import 'widgets/calculator_card.dart';", "import 'widgets/concentric_rings_painter.dart';"]
last_import = content.rfind('import ')
if last_import != -1:
    end_of_import = content.find('\\n', last_import)
    content = content[:end_of_import+1] + '\\n'.join(imports) + '\\n' + content[end_of_import+1:]

write_file('lib/features/budget/budget_screen.dart', content)
