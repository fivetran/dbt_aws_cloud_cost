# dbt_aws_cloud_cost v0.1.0
This is the initial release of the formatted_aws_cloud_cost dbt package!

## 📣 What does this dbt package do?

This package models AWS Cloud Cost data from [Fivetran's connector](https://fivetran.com/docs/applications/aws_cloud_cost). It uses data in the format described by [this ERD](https://fivetran.com/docs/applications/aws_cloud_cost#schemainformation).

The main focus of the package is to transform the core object tables into analytics-ready models, including:
<!--section="aws_cloud_cost_model"-->
  - Materializes [AWS Cloud Cost staging tables](https://fivetran.github.io/dbt_aws_cloud_cost/#!/overview/aws_cloud_cost/models/?g_v=1) which leverage data in the format described by the [AWS Cost & Usage Report](https://docs.aws.amazon.com/cur/latest/userguide/table-dictionary-cur2.html). These staging tables clean, test, and prepare your AWS Cloud Cost data from [Fivetran's connector](https://fivetran.com/docs/connectors/applications/aws-cost-report) for analysis by doing the following:
    - Names columns for consistency across all packages and for easier analysis
        - Primary keys are renamed from `id` to `<table name>_id`.
        - Column names are shortened for convenience and to avoid redundancy.
    - Adds column-level testing where applicable. For example, all primary keys are tested for uniqueness and non-null values.
    - Takes the latest export of each account's billing month report.
    - Generates a comprehensive data dictionary of your AWS Cloud Cost data through the [dbt docs site](https://fivetran.github.io/dbt_aws_cloud_cost/).
  - Creates the below analytics-ready end models.

> This package does not apply freshness tests.

The following table provides a detailed list of all models materialized within this package by default.
> TIP: See more details about these models in the package's [dbt docs site](https://fivetran.github.io/dbt_aws_cloud_cost/#!/overview/aws_cloud_cost).

| **model**                 | **description**                                                                                                    |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| [aws_cloud_cost__daily_overview](https://github.com/fivetran/dbt_aws_cloud_cost/blob/main/models/aws_cloud_cost__daily_overview.sql)  | Daily aggregation of the [Standard](https://docs.aws.amazon.com/cur/latest/userguide/dataexports-create-standard.html) Cost & Usage Report (2.0) exported from AWS. Includes slew of commonly analyzed dimensions related to [billing](https://docs.aws.amazon.com/cur/latest/userguide/table-dictionary-cur2-bill.html), [pricing](https://docs.aws.amazon.com/cur/latest/userguide/table-dictionary-cur2-pricing.html), [line item](https://docs.aws.amazon.com/cur/latest/userguide/table-dictionary-cur2-line-item.html) buckets, and [products](https://docs.aws.amazon.com/cur/latest/userguide/table-dictionary-cur2-product.html). Contains both high-level cost and usage metrics, along with all metrics related to [reservations](https://docs.aws.amazon.com/cur/latest/userguide/table-dictionary-cur2-reservation.html) and [savings plans](https://docs.aws.amazon.com/cur/latest/userguide/table-dictionary-cur2-savings-plan.html). Also includes financial reporting fieds relating to invoices and billing periods. |
| [aws_cloud_cost__daily_product_report](https://github.com/fivetran/dbt_aws_cloud_cost/blob/main/models/aws_cloud_cost__daily_product_report.sql)  | Daily view of each account's use of and associated costs from individual AWS products for each billing period.   |
| [aws_cloud_cost__daily_compute_report](https://github.com/fivetran/dbt_aws_cloud_cost/blob/main/models/aws_cloud_cost__daily_compute_report.sql)  | Daily view of each account's use of and associated costs from different Amazon Elastic Compute Cloud (EC2) instances for each billing period.   |