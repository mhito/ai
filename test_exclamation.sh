#!/bin/bash

# Test script for exclamation mark execute mode

echo "Testing AI exclamation mark execute mode..."
echo ""

# Test 1: Check if ! detection is in the code
echo "Test 1: Checking if ! detection exists..."
if grep -q '!\$' ./ai; then
  echo "✓ Exclamation mark detection found"
else
  echo "✗ Exclamation mark detection not found"
  exit 1
fi

# Test 2: Check if \! escape is handled
echo "Test 2: Checking if \\! escape is handled..."
if grep -q 'elif.*\\!' ./ai; then
  echo "✓ Escape handling found"
else
  echo "✗ Escape handling not found"
  exit 1
fi

# Test 3: Test with ! (should enter execute mode)
echo "Test 3: Testing with ! (should enter execute mode)..."
OUTPUT=$(echo "n" | ai "lista los archivos!" 2>&1)
if echo "$OUTPUT" | grep -q "run.*? (Y/n):"; then
  echo "✓ Execute mode activated with !"
else
  echo "✗ Execute mode not activated with !"
  echo "Output: $OUTPUT"
  exit 1
fi

# Test 4: Test without ! (should NOT enter execute mode)
echo "Test 4: Testing without ! (should NOT enter execute mode)..."
OUTPUT=$(ai "lista los archivos" 2>&1)
if ! echo "$OUTPUT" | grep -q "run.*? (Y/n):"; then
  echo "✓ Execute mode not activated without !"
else
  echo "✗ Execute mode incorrectly activated without !"
  echo "Output: $OUTPUT"
  exit 1
fi

# Test 5: Test with \! (should NOT enter execute mode)
echo "Test 5: Testing with \\! (should NOT enter execute mode)..."
OUTPUT=$(ai "lista los archivos\!" 2>&1)
if ! echo "$OUTPUT" | grep -q "run.*? (Y/n):"; then
  echo "✓ Execute mode not activated with \\!"
else
  echo "✗ Execute mode incorrectly activated with \\!"
  echo "Output: $OUTPUT"
  exit 1
fi

echo ""
echo "All tests passed! ✓"
echo ""
echo "Summary:"
echo "  - ai \"question!\"   → Execute mode ON"
echo "  - ai \"question\"    → Execute mode OFF"
echo "  - ai \"question\\!\"  → Execute mode OFF"
