@echo off
REM ============================================================================
REM 🪟 Simple Windows Testing Commands
REM Tests that work without Docker/WSL configuration headaches
REM ============================================================================

echo 🧪 Simple Bootstrap Testing
echo ============================

echo.
echo 🔍 Test 1: Basic Script Validation
echo -----------------------------------
bash -n bootstrap-steamos.sh
if %ERRORLEVEL%==0 (
    echo ✅ Syntax check passed
) else (
    echo ❌ Syntax errors found
    pause
    exit /b 1
)

echo.
echo 📋 Test 2: Script Analysis  
echo ---------------------------
bash test/analyze-script.sh

echo.
echo 📝 Test 3: Manual Review Checklist
echo -----------------------------------
echo Please manually verify these items:
echo.
echo [ ] All package names are spelled correctly
echo [ ] Flatpak app IDs are valid (check flathub.org)
echo [ ] No hardcoded usernames or paths
echo [ ] Interactive prompts have timeouts
echo [ ] Error handling is comprehensive
echo [ ] Script can run multiple times safely (idempotent)

echo.
echo 🚀 Next Steps:
echo ==============
echo 1. If you have WSL2: bash test/wsl-test-setup.sh
echo 2. Or download VirtualBox + SteamOS ISO for full test
echo 3. Create system backup before switching
echo 4. Run bootstrap script on fresh SteamOS install

pause