# Security Controls Checklist

## Secrets Detection

Review code and configuration for exposed credentials before merge.

## Dependency Scanning

Review direct and transitive dependencies for known vulnerabilities and unsupported versions.

## IaC Scanning

Check infrastructure definitions for misconfiguration patterns before deployment.

## SAST

Review application code for insecure patterns and common implementation mistakes.

## Container Image Scanning

Evaluate build artifacts before deployment or registry promotion.

## SBOM Concept

Maintain bill-of-materials visibility for software components used in build artifacts.

## Approval Gates

Use explicit promotion controls before higher-environment release decisions.

## Audit Logs

Retain pipeline results, review history, approvals, and artifact metadata.

## Rollback Planning

Document rollback triggers, ownership, and safe recovery steps before deployment.

## Environment Promotion

Promote artifacts through defined environments rather than rebuilding differently at each stage.
