# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Salesforce DX project template configured for CI/CD automation. It demonstrates a three-tier architecture pattern for Salesforce development with automated PR validation using GitHub Actions.

## Common Commands

### Salesforce CLI Commands

**Authentication:**
```bash
# Authenticate to an org using SFDX URL
sf org login sfdx-url --sfdx-url-file ./SFDX_INTEGRATION_URL.txt --set-default --alias integration
```

**Deploy and Validate:**
```bash
# Deploy to org (dry-run/check-only)
sf project deploy start --source-dir force-app --dry-run --test-level RunLocalTests

# Deploy source (actual deployment)
sf project deploy start --source-dir force-app --test-level RunLocalTests

# Deploy specific changed sources (used in CI/CD)
sf project deploy start --source-dir changed-sources/force-app --dry-run --test-level RunLocalTests
```

**Generate Delta Packages:**
```bash
# Create delta package between commits
sf sgd source delta --to "HEAD" --from "<base-sha>" --output-dir changed-sources/ --generate-delta --source-dir force-app/
```

**Code Quality Scanning:**
```bash
# Run PMD and ESLint code analyzer
sf code-analyzer run --rule-selector pmd --rule-selector eslint --target 'changed-sources/**/*' --output-file 'pmdScanResults.sarif.json'

# Run Lightning Flow Scanner
sf flow:scan --directory changed-sources/force-app/main/default/flows
```

**Required Plugins:**
- `@salesforce/plugin-code-analyzer@5.5.0` - Static code analysis
- `sfdx-git-delta@6.22.0` - Delta deployment generation
- `lightning-flow-scanner@5.7.2` - Flow validation

Install with:
```bash
echo y | sf plugins install @salesforce/plugin-code-analyzer@5.5.0
echo y | sf plugins install sfdx-git-delta@6.22.0
echo y | sf plugins install lightning-flow-scanner@5.7.2
```

### Testing

**Run Apex Tests:**
```bash
# Run all local tests
sf apex run test --test-level RunLocalTests --result-format human --code-coverage

# Run specific test class
sf apex run test --tests AccountControllerTest --result-format human --code-coverage
```

## Architecture

### Three-Tier Architecture Pattern

The codebase follows a strict three-tier separation pattern:

1. **Controller Layer** (`*Controller.cls`)
   - Handles UI interactions (LWC/Aura components)
   - Uses `@AuraEnabled` methods for Lightning components
   - Example: `AccountController.cls`, `ContactController.cls`, `CaseController.cls`

2. **Service Layer** (`*ServiceManager.cls`)
   - Contains business logic and validation
   - Intermediary between controllers and data access
   - Example: `AccountServiceManager.cls`, `ContactServiceManager.cls`, `CaseServiceManager.cls`

3. **Data Access Layer** (`*DataManager.cls`)
   - Direct database operations (SOQL queries, DML)
   - Uses `WITH SECURITY_ENFORCED` for FLS/CRUD enforcement
   - Example: `AccountDataManager.cls`, `ContactDataManager.cls`, `CaseDataManager.cls`

**Pattern:** For each domain object (Account, Contact, Case), there are three corresponding classes:
- `{Object}Controller` → `{Object}ServiceManager` → `{Object}DataManager`

### Test Classes

Each class has a corresponding test class with the `Test` suffix:
- `AccountControllerTest.cls`, `AccountServiceManagerTest.cls`, `AccountDataManagerTest.cls`

The CI/CD pipeline automatically includes test classes when their corresponding non-test class is modified.

### Lightning Web Components

Located in `force-app/main/default/lwc/`:
- `accountRecordList` - Displays account records
- `contactRecordList` - Displays contact records
- `caseRecordList` - Displays case records

### Aura Components

Located in `force-app/main/default/aura/`:
- `AccountRecordsDisplay`
- `ContactRecordsDisplay`
- `CaseRecordsDisplay`

### Flows

Screen flows located in `force-app/main/default/flows/`:
- `Screen_Case_CreateCase.flow-meta.xml`

## CI/CD Pipeline

### GitHub Actions Workflow

The workflow in `.github/workflows/automation-viseo-tma.yml` runs on PR creation/updates and performs:

1. **Setup:** Install Salesforce CLI, Java (for code analyzer), and required plugins
2. **Authentication:** Connect to integration org using `SFDX_INTEGRATION_URL` secret
3. **Delta Generation:** Create package with only changed metadata between PR HEAD and base branch
4. **Test Class Discovery:** Automatically add test classes for modified Apex classes
5. **Static Analysis:** Run PMD and ESLint rules, generate SARIF report
6. **Flow Validation:** Scan flows with Lightning Flow Scanner, post results as PR comment
7. **Validation Deploy:** Check-only deployment with `RunLocalTests`
8. **SARIF Upload:** Upload code quality issues to GitHub Security tab

### CI/CD Key Features

- **Delta Deployments:** Only changed metadata is validated/deployed
- **Automatic Test Inclusion:** When `FooBar.cls` changes, `FooBarTest.cls` is automatically included
- **PR Comments:** Flow scan results are posted directly on the PR
- **Security Integration:** Code quality issues appear in GitHub's Security tab via SARIF upload
- **Skip Empty SARIF:** Only uploads SARIF files that contain actual issues

### Required GitHub Secrets

- `SFDX_INTEGRATION_URL` - Org authentication URL (obtain via `sf org display --verbose`)

### Branch Strategy

- Main branch: `main`
- Feature branches: `feature/**` (current: `feature/flowValidation`)
- PR validation triggers on: `[opened, synchronize]` events

## Development Notes

### Code Quality Rules

The project enforces PMD and ESLint rules. Some classes intentionally violate rules for demonstration:
- `AccountController.cls:10` - Annotations naming convention violation (Medium)
- `AccountController.cls:16` - Field naming conventions violation (High)

### Security Practices

- All SOQL queries use `WITH SECURITY_ENFORCED` for field-level security
- Controllers use `with sharing` keyword for record-level security
- API version: 64.0

### Project Configuration

- **Package Directory:** `force-app/` (default)
- **Login URL:** https://login.salesforce.com
- **Node Dependency:** `jq` (for JSON processing in CI/CD)