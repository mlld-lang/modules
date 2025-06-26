#!/bin/bash

# mlld v2 Module Test Runner
# Run from the modules directory

echo "🚀 Running mlld v2 module tests..."
echo "================================="

# Change to modules directory
cd /Users/adam/dev/mlld/modules || exit 1

# Array of test scripts
tests=(
    "01-basic-imports"
    "02-pipeline-tests" 
    "03-real-world-patterns"
    "04-edge-cases"
)

# Run each test
for test in "${tests[@]}"; do
    echo -e "\n📋 Running: $test"
    echo "--------------------------------"
    
    if mlld-v2 run "$test"; then
        echo -e "✅ $test completed successfully"
    else
        echo -e "❌ $test failed with exit code $?"
    fi
    
    echo -e "\nPress Enter to continue..."
    read -r
done

echo -e "\n🎉 All tests completed!"
echo "================================="
echo ""
echo "Next steps:"
echo "1. Review any errors or unexpected output"
echo "2. Create GitHub issues for any bugs found"
echo "3. Run individual module test files in llm/tests/"
echo ""
echo "To run module tests:"
echo "cd /Users/adam/dev/mlld/modules/llm/tests"
echo "mlld-v2 string.test.mld"
echo ""
echo "To run individual scripts:"
echo "cd /Users/adam/dev/mlld/modules"
echo "mlld-v2 run 01-basic-imports"