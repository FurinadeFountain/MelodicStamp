#!/bin/bash
# run_tests.sh - Melodic Stamp 测试运行脚本
# 此脚本用于在 macOS 上运行所有测试并生成报告

set -e

# 颜色输出
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PROJECT_NAME="Melodic Stamp"
SCHEME="MelodicStamp"
DESTINATION="platform=macOS"

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}   Melodic Stamp Test Suite${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 检查是否在 macOS 上运行
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}❌ Error: This script must be run on macOS${NC}"
    echo -e "${YELLOW}   Melodic Stamp requires macOS 15.0+ to build and test${NC}"
    exit 1
fi

# 检查 Xcode 是否安装
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}❌ Error: xcodebuild not found${NC}"
    echo -e "${YELLOW}   Please install Xcode from the App Store${NC}"
    exit 1
fi

# 检查 Xcode 版本
XCODE_VERSION=$(xcodebuild -version | head -n 1 | awk '{print $2}')
echo -e "${BLUE}🔧 Xcode Version: ${XCODE_VERSION}${NC}"
echo ""

# 函数：运行测试目标
run_test_target() {
    local target=$1
    local test_name=$2

    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}🧪 Running ${test_name} Tests...${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    if xcodebuild test \
        -scheme "$SCHEME" \
        -destination "$DESTINATION" \
        -only-testing:"$target" \
        2>&1 | grep -E "(Test Case|Test Suite|passed|failed|\*\* TEST)"; then
        echo ""
        echo -e "${GREEN}✅ ${test_name} Tests Passed${NC}"
        return 0
    else
        echo ""
        echo -e "${RED}❌ ${test_name} Tests Failed${NC}"
        return 1
    fi
}

# 清理之前的构建
echo -e "${YELLOW}🧹 Cleaning previous builds...${NC}"
xcodebuild clean \
    -scheme "$SCHEME" \
    > /dev/null 2>&1

echo -e "${GREEN}✅ Clean complete${NC}"
echo ""

# 运行所有测试目标
FAILED_TESTS=()

# 测试 1: ModelsTests
if ! run_test_target "ModelsTests" "Models"; then
    FAILED_TESTS+=("ModelsTests")
fi
echo ""

# 测试 2: InterfaceTests
if ! run_test_target "InterfaceTests" "Interface"; then
    FAILED_TESTS+=("InterfaceTests")
fi
echo ""

# 测试 3: MelodicStampTests
if ! run_test_target "MelodicStampTests" "MelodicStamp"; then
    FAILED_TESTS+=("MelodicStampTests")
fi
echo ""

# 生成代码覆盖率报告
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}📊 Generating Code Coverage Report...${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

RESULT_BUNDLE="TestResults.xcresult"

xcodebuild test \
    -scheme "$SCHEME" \
    -destination "$DESTINATION" \
    -enableCodeCoverage YES \
    -resultBundlePath "$RESULT_BUNDLE" \
    -quiet

if [ -d "$RESULT_BUNDLE" ]; then
    echo -e "${GREEN}✅ Coverage report generated${NC}"
    echo ""
    echo -e "${YELLOW}📈 Coverage Summary:${NC}"
    echo ""
    xcrun xccov view --report "$RESULT_BUNDLE" 2>/dev/null || echo -e "${YELLOW}   (Coverage data available in $RESULT_BUNDLE)${NC}"
    echo ""
    echo -e "${BLUE}💡 To view detailed coverage:${NC}"
    echo -e "   open $RESULT_BUNDLE"
else
    echo -e "${YELLOW}⚠️  Coverage report not generated${NC}"
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}   Test Summary${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 显示结果
if [ ${#FAILED_TESTS[@]} -eq 0 ]; then
    echo -e "${GREEN}✨ All tests passed! ✨${NC}"
    echo ""
    exit 0
else
    echo -e "${RED}❌ Some tests failed:${NC}"
    for test in "${FAILED_TESTS[@]}"; do
        echo -e "${RED}   - $test${NC}"
    done
    echo ""
    echo -e "${YELLOW}💡 Check the output above for details${NC}"
    echo ""
    exit 1
fi
