[PR #9](https://github.com/fivetran/dbt_aws_cloud_cost/pull/9) includes the following updates:

### Under the Hood - July 2025 Updates

- Updated conditions in `.github/workflows/auto-release.yml`.
- Added `.github/workflows/generate-docs.yml`.
- Added `+docs: show: False` to `integration_tests/dbt_project.yml`.
- Migrated `flags` (e.g., `send_anonymous_usage_stats`, `use_colors`) from `sample.profiles.yml` to `integration_tests/dbt_project.yml`.
- Updated `maintainer_pull_request_template.md` with improved checklist.
- Refreshed README tag block:
  - Standardized Quickstart-compatible badge set
  - Left-aligned and positioned below the H1 title.
- Updated Python image version to `3.10.13` in `pipeline.yml`.
- Added `CI_DATABRICKS_DBT_CATALOG` to:
  - `.buildkite/hooks/pre-command` (as an export)
  - `pipeline.yml` (under the `environment` block, after `CI_DATABRICKS_DBT_TOKEN`)
- Added `certifi==2025.1.31` to `requirements.txt` (if missing).
- Updated `.gitignore` to exclude additional DBT, Python, and system artifacts.

# dbt_aws_cloud_cost version.version

## Documentation
- Added Quickstart model counts to README. ([#8](https://github.com/fivetran/dbt_aws_cloud_cost/pull/8))
- Corrected references to connectors and connections in the README. ([#8](https://github.com/fivetran/dbt_aws_cloud_cost/pull/8))

# dbt_aws_cloud_cost v0.1.0
This is the initial release of the `aws_cloud_cost` dbt package!

## 📣 What does this dbt package do?

This package models AWS Cloud Cost data from [Fivetran's AWS Cost Report connector](https://fivetran.com/docs/connectors/applications/aws-cost-report). It uses data in the format described by the [AWS Cost & Usage Report](https://docs.aws.amazon.com/cur/latest/userguide/table-dictionary-cur2.html).

The main focus of the package is to transform the core object tables into analytics-ready models, including:
  - Materializes [AWS Cloud Cost staging tables](https://fivetran.github.io/dbt_aws_cloud_cost/#!/model/model.aws_cloud_cost.stg_aws_cloud_cost__report) which leverage data in the format described by the [AWS Cost & Usage Report](https://docs.aws.amazon.com/cur/latest/userguide/table-dictionary-cur2.html). These staging tables clean, test, and prepare your AWS Cloud Cost data from [Fivetran's connector](https://fivetran.com/docs/connectors/applications/aws-cost-report) for analysis by doing the following:
    - Names columns for consistency across all packages and for easier analysis:
        - Column names are shortened for convenience and to avoid redundancy.
    - Takes the latest export of each account's billing month report.
  - Creates analytics-ready end models for monitoring and investigating cost & usage of different AWS services across your organizations.
  - Generates a comprehensive data dictionary of both your AWS Cloud Cost source and modeled data through the [dbt docs site](https://fivetran.github.io/dbt_aws_cloud_cost/).

> This package does not apply freshness tests.

The following table provides a detailed list of all models materialized within this package by default.
> TIP: See more details about these models in the package's [dbt docs site](https://fivetran.github.io/dbt_aws_cloud_cost/#!/overview/aws_cloud_cost).

| **model**                 | **description**                                                                                                    |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| [aws_cloud_cost__daily_overview](https://github.com/fivetran/dbt_aws_cloud_cost/blob/main/models/aws_cloud_cost__daily_overview.sql)  | Daily aggregation of the [Standard](https://docs.aws.amazon.com/cur/latest/userguide/dataexports-create-standard.html) Cost & Usage Report (2.0) exported from AWS. Includes slew of commonly analyzed dimensions related to [billing](https://docs.aws.amazon.com/cur/latest/userguide/table-dictionary-cur2-bill.html), [pricing](https://docs.aws.amazon.com/cur/latest/userguide/table-dictionary-cur2-pricing.html), [line item](https://docs.aws.amazon.com/cur/latest/userguide/table-dictionary-cur2-line-item.html) buckets, and [products](https://docs.aws.amazon.com/cur/latest/userguide/table-dictionary-cur2-product.html). Contains both high-level cost and usage metrics, along with all metrics related to [reservations](https://docs.aws.amazon.com/cur/latest/userguide/table-dictionary-cur2-reservation.html) and [savings plans](https://docs.aws.amazon.com/cur/latest/userguide/table-dictionary-cur2-savings-plan.html). Also includes financial reporting fieds relating to invoices and billing periods. |
| [aws_cloud_cost__daily_product_report](https://github.com/fivetran/dbt_aws_cloud_cost/blob/main/models/aws_cloud_cost__daily_product_report.sql)  | Daily view of each account's use of and associated costs from individual AWS products for each billing period.   |
| [aws_cloud_cost__daily_instance_report](https://github.com/fivetran/dbt_aws_cloud_cost/blob/main/models/aws_cloud_cost__daily_instance_report.sql)  | Daily view of each account's use of and associated costs from different Amazon Elastic Compute Cloud (EC2) instances for each billing period.   |