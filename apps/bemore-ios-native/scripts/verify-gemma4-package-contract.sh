#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

expected_repo="welcoma/gemma-4-E2B-it-q4f16_1-MLC"
expected_model_id="gemma-4-E2B-it-q4f16_1-MLC"
expected_folder="BundledModels/gemma-4-E2B-it-q4f16_1-MLC"

check_file_contains() {
  local file="$1"
  local needle="$2"
  if ! grep -Fq "$needle" "$file"; then
    echo "::error title=Gemma 4 package contract drift::$file does not contain expected value: $needle" >&2
    exit 1
  fi
}

check_file_not_contains() {
  local file="$1"
  local needle="$2"
  if grep -Fq "$needle" "$file"; then
    echo "::error title=Gemma 4 package contract drift::$file still contains forbidden value: $needle" >&2
    exit 1
  fi
}

check_file_contains "scripts/prepare-bundled-mlc-model.sh" "$expected_repo"
check_file_contains "scripts/prepare-bundled-mlc-model.sh" "$expected_model_id"
check_file_contains "BeMoreAgentShell/MLCPackageInstaller.swift" "$expected_repo"
check_file_contains "BeMoreAgentShell/MLCPackageInstaller.swift" "$expected_model_id"
check_file_contains "BeMoreAgentShell/BundledModelCatalog.swift" "gemma4_E2B_IT_Q4F16_1"
check_file_contains "BeMoreAgentShell/AppModels.swift" "Gemma 4 E2B IT MLC"
check_file_contains "mlc-package-config.json" "HF://$expected_repo"
check_file_contains "GEMMA4_PACKAGE_CONTRACT.md" "codysumpter-cloud/gemma"
check_file_contains "GEMMA4_PACKAGE_CONTRACT.md" "$expected_repo"

check_file_not_contains "scripts/prepare-bundled-mlc-model.sh" "gemma-2-2b-it"
check_file_not_contains "BeMoreAgentShell/MLCPackageInstaller.swift" "gemma-2-2b-it"
check_file_not_contains "mlc-package-config.json" "gemma-2-2b-it"

if [[ -d "BundledModels" && ! -d "$expected_folder" ]]; then
  echo "::error title=Gemma 4 bundle folder mismatch::BundledModels exists but $expected_folder is missing." >&2
  exit 1
fi

echo "Gemma 4 package contract verified."
