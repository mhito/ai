#!/bin/bash

# Test script for execute mode functionality

echo "Testing AI execute mode..."
echo ""

# Test 1: Check if -x flag is recognized
echo "Test 1: Checking if -x flag is recognized..."
if grep -q "EXECUTE_MODE" ./ai; then
  echo "✓ EXECUTE_MODE variable found"
else
  echo "✗ EXECUTE_MODE variable not found"
  exit 1
fi

# Test 2: Check if prompt_execute function exists
echo "Test 2: Checking if prompt_execute function exists..."
if grep -q "prompt_execute()" ./ai; then
  echo "✓ prompt_execute function found"
else
  echo "✗ prompt_execute function not found"
  exit 1
fi

# Test 3: Check if the function has the correct prompt format
echo "Test 3: Checking prompt format..."
if grep -q 'printf "run %s? (Y/n): "' ./ai; then
  echo "✓ Correct prompt format found"
else
  echo "✗ Prompt format not found"
  exit 1
fi

# Test 4: Check if execute mode is called at the end
echo "Test 4: Checking if execute mode is called..."
if grep -q 'prompt_execute "$COMMAND"' ./ai; then
  echo "✓ Execute mode call found"
else
  echo "✗ Execute mode call not found"
  exit 1
fi

echo ""
echo "All tests passed! ✓"
