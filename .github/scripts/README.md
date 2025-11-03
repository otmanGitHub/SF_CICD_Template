# GitHub Actions Scripts

This directory contains utility scripts for the CI/CD pipeline.

## format-flow-scan-results.py

Formats Lightning Flow Scanner output into a readable Markdown table for PR comments.

### Usage

```bash
python3 format-flow-scan-results.py <input_file> <output_file>
```

**Parameters:**
- `input_file`: Path to the cleaned Flow Scanner text output (default: `lightning-flow-scan_result_cleanResult.txt`)
- `output_file`: Path to the output Markdown file (default: `flow-scan-comment.md`)

### Example

```bash
# Test locally
python3 format-flow-scan-results.py test-flow-scan-sample.txt test-output.md
```

### Output Format

The script generates a Markdown formatted report with:
- **Summary header** with total issues and flow count
- **Flow sections** with detailed tables for each flow:
  - Severity (with emoji indicators: 🔴 error, 🟡 warning, 🔵 note)
  - Rule violated
  - Element type
  - Element name
- **Summary table** with issue counts by severity

### Integration in Workflow

The script is automatically called in `.github/workflows/automation-viseo-tma.yml`:

```yaml
- name: 'Format Flow Scanner results'
  run: |
      python3 .github/scripts/format-flow-scan-results.py \
        lightning-flow-scan_result_cleanResult.txt \
        flow-scan-comment.md
```

The formatted output is then posted as a PR comment:

```yaml
- name: 'Comment flow scan result on PR'
  run: |
      gh pr comment ${{ github.event.pull_request.number }} \
        --edit-last \
        --body-file flow-scan-comment.md
```

## format-flow-scan-results.sh

Alternative bash implementation (deprecated in favor of Python version).
