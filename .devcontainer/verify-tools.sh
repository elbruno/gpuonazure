#!/bin/bash
# Quick health check for devcontainer toolchain
set -e

OK=()
FAIL=()

check() {
  local name="$1" cmd="$2" critical="$3"
  if eval "$cmd" >/dev/null 2>&1; then
    OK+=("$name")
  else
    if [ "$critical" = "true" ]; then
      FAIL+=("$name (critical)")
    else
      FAIL+=("$name")
    fi
  fi
}

echo "[verify-tools] Starting toolchain verification"

check "bash" "command -v bash" true
check "coreutils (ls)" "command -v ls" true
check "Java" "command -v java" false
check "Maven" "command -v mvn" false
check ".NET" "command -v dotnet" false
check "Node.js" "command -v node" false
check "npm" "command -v npm" false
check "Azure CLI" "command -v az" false
check "Aspire CLI" "command -v aspire" false
check "CUDA toolkit (nvcc)" "command -v nvcc" false
check "nvidia-smi" "command -v nvidia-smi" false

echo ""
echo "[verify-tools] Summary"
printf '  ✓ %s\n' "${OK[@]}"
if [ ${#FAIL[@]} -gt 0 ]; then
  printf '  ✗ %s\n' "${FAIL[@]}"
fi

# Guidance for missing non-critical tools
if [[ " ${FAIL[*]} " =~ bash ]]; then
  echo "[verify-tools] CRITICAL: bash missing from PATH. Investigate PATH restoration logic."
fi

if [[ " ${FAIL[*]} " =~ Java ]] || [[ " ${FAIL[*]} " =~ Maven ]]; then
  echo "[verify-tools] Java/Maven absent: may not have run post-install yet. Re-run bootstrap or execute post-install manually."
fi
if [[ " ${FAIL[*]} " =~ dotnet ]]; then
  echo "[verify-tools] .NET SDK absent. Expect installation during post-install script."
fi
if [[ " ${FAIL[*]} " =~ Aspire ]]; then
  echo "[verify-tools] Aspire CLI not found. It is optional; rerun post-install if needed.""
fi
if [[ " ${FAIL[*]} " =~ nvcc ]] || [[ " ${FAIL[*]} " =~ nvidia-smi ]]; then
  echo "[verify-tools] GPU utilities missing (expected on non-GPU hosts). Safe to ignore if developing CPU-only.""
fi

echo "[verify-tools] Done"
