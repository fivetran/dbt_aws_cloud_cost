<!--section="aws-cloud-cost_transformation_model"-->
# Aws Cloud Cost dbt Package

This dbt package transforms data from Fivetran's Aws Cloud Cost connector into analytics-ready tables.

## Resources

- Number of materialized models¹: 5
- Connector documentation
  - [AWS Cloud Cost connector documentation](https://fivetran.com/docs/connectors/applications/aws-cost-report)
  - [AWS Cost & Usage Report](https://fivetran.com/docs/connectors/applications/aws-cost-report#syncoverview)
- dbt package documentation
  - [GitHub repository](https://github.com/fivetran/dbt_aws_cloud_cost)
  - [dbt Docs](https://fivetran.github.io/dbt_aws_cloud_cost/#!/overview)
  - [DAG](https://fivetran.github.io/dbt_aws_cloud_cost/#!/overview?g_v=1)
  - [Changelog](https://github.com/fivetran/dbt_aws_cloud_cost/blob/main/CHANGELOG.md)
- dbt Core™ supported versions
  - `>=1.3.0, <3.0.0`

## What does this dbt package do?
This package enables you to monitor and investigate cost & usage of different AWS services across your organizations. It creates enriched models with metrics focused on billing, pricing, line item buckets, products, reservations, and savings plans.


### Output schema
Final output tables are generated in the following target schema:

```
<your_database>.<connector/schema_name>_aws_cloud_cost
```

### Final output tables

By default, this package materializes the following final tables:

| Table | Description |
| :---- | :---- |
| [aws_cloud_cost__daily_overview](https://fivetran.github.io/dbt_aws_cloud_cost/#!/model/model.aws_cloud_cost.aws_cloud_cost__daily_overview) | Provides a comprehensive daily view of AWS costs and usage across all services, accounts, and billing dimensions from the [Standard](https://docs.aws.amazon.com/cur/latest/userguide/dataexports-create-standard.html) Cost & Usage Report (2.0) to monitor spending patterns, optimize costs, and track [reservations](https://docs.aws.amazon.com/cur/latest/userguide/table-dictionary-cur2-reservation.html) and [savings plans](https://docs.aws.amazon.com/cur/latest/userguide/table-dictionary-cur2-savings-plan.html). <br></br>**Example Analytics Questions:**<ul><li>What are our daily AWS costs by [billing](https://docs.aws.amazon.com/cur/latest/userguide/table-dictionary-cur2-bill.html) account, [product](https://docs.aws.amazon.com/cur/latest/userguide/table-dictionary-cur2-product.html), or region?</li><li>How much are we saving through reservations and savings plans compared to on-demand pricing?</li><li>Which [line item](https://docs.aws.amazon.com/cur/latest/userguide/table-dictionary-cur2-line-item.html) buckets or [pricing](https://docs.aws.amazon.com/cur/latest/userguide/table-dictionary-cur2-pricing.html) categories are driving the biggest spending increases?</li></ul>|
| [aws_cloud_cost__daily_product_report](https://fivetran.github.io/dbt_aws_cloud_cost/#!/model/model.aws_cloud_cost.aws_cloud_cost__daily_product_report) | Breaks down daily AWS spending by individual product and service for each account to identify which services consume the most budget and where optimization opportunities exist. <br></br>**Example Analytics Questions:**<ul><li>Which AWS products or services drive the highest costs by account?</li><li>How are product-specific costs trending day-over-day or month-over-month?</li><li>Where should we focus cost optimization efforts based on product spending patterns?</li></ul>|
| [aws_cloud_cost__daily_instance_report](https://fivetran.github.io/dbt_aws_cloud_cost/#!/model/model.aws_cloud_cost.aws_cloud_cost__daily_instance_report) | Analyzes daily costs and usage for EC2 instances across all accounts to optimize compute spending and identify underutilized or oversized instances. <br></br>**Example Analytics Questions:**<ul><li>Which EC2 instance types generate the highest daily costs by account?</li><li>How does EC2 instance usage and spending vary across different accounts or environments?</li><li>Are there opportunities to right-size instances based on usage patterns?</li></ul>|

¹ Each Quickstart transformation job run materializes these models if all components of this data model are enabled. This count includes all staging, intermediate, and final models materialized as `view`, `table`, or `incremental`.

---

## Prerequisites
To use this dbt package, you must have the following:

- At least one Fivetran AWS Cloud Cost connection syncing data into your destination.
- A **BigQuery**, **Snowflake**, **Redshift**, **Databricks**, or **PostgreSQL** destination.

## How do I use the dbt package?
You can either add this dbt package in the Fivetran dashboard or import it into your dbt project:

- To add the package in the Fivetran dashboard, follow our [Quickstart guide](https://fivetran.com/docs/transformations/data-models/quickstart-management#quickstartmanagement).
- To add the package to your dbt project, follow the setup instructions in the dbt package's [README file](https://github.com/fivetran/dbt_aws_cloud_cost/blob/main/README.md#how-do-i-use-the-dbt-package) to use this package.

> DISCLAIMER: This package transforms source data of potentially very high volumes. Please be aware of the size of your dataset(s) and take this into consideration when configuring the frequency with which you will orchestrate the package models. See [Additional configurations](https://github.com/fivetran/dbt_aws_cloud_cost?tab=readme-ov-file#optional-additional-configurations) for tools to mitigate compute and storage costs.

<!--section-end-->

### Install the package
Include the following AWS Cloud Cost package version in your `packages.yml` file:
> TIP: Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.
```yml
packages:
  - package: fivetran/aws_cloud_cost
    version: [">=0.3.0", "<0.4.0"] # we recommend using ranges to capture non-breaking changes automatically
```

##### Databricks dispatch configuration
If you are using a Databricks destination with this package, you must add the following (or a variation of the following) dispatch configuration within your `dbt_project.yml`. This is required in order for the package to accurately search for macros within the `dbt-labs/spark_utils` then the `dbt-labs/dbt_utils` packages respectively.
```yml
dispatch:
  - macro_namespace: dbt_utils
    search_order: ['spark_utils', 'dbt_utils']
```

### Define database, schema, and table name variables

##### Option A: Single connection
By default, this package assumes your AWS Cost & Usage Report data lives in the following location:

- Your `target.database`
- A schema called `aws_cloud_cost`
- A table called `aws_cloud_cost_report`

In the very likely case that your AWS Cloud Cost source data lives someplace else (for example, if your AWS Cloud Cost schema is named `aws_cloud_cost_fivetran` or your table is called `aws_billing`), add the following configuration to your root `dbt_project.yml` file:

```yml
# dbt_project.yml

vars:
    aws_cloud_cost_database: your_database_name # default: target.database
    aws_cloud_cost_schema: your_schema_name # default: aws_cloud_cost
    aws_cloud_cost_report_identifier: your_table_name # default: aws_cloud_cost_report
```

##### Option B: Union multiple connections
If you have multiple AWS Cloud Cost connections in Fivetran and would like to use this package on all of them simultaneously, we have provided functionality to do so. The package will union all of the data together and pass the unioned table into the transformations. You will be able to see which source it came from (the `database.schema.table`, NOT the source `name`) in the `source_relation` column of each model.

To use this functionality, you will need to configure the `aws_cloud_cost_sources` dictionary-list in your root `dbt_project.yml` file. For each source, provide the appropriate `database`, `schema`, and `table` for each dataset:

```yml
# dbt_project.yml

vars:
  aws_cloud_cost_sources:
    - database: source_databse_name # default: target.database
      schema: source_schema_name
      table: source_table_name

    - database: 'my-db-example'
      schema: aws_cost_schema_example
      table: report_table_example

    # include as many sources as you'd like
```

###### Recommended: Incorporate unioned sources into DAG
> NOTE: The native `aws_cloud_cost` source connection set up in the package will not function when the union-feature is utilized. Although the package will run correctly and the data will be correctly transformed, you will not observe the sources linked to the package models in the Directed Acyclic Graph (DAG).

To properly incorporate all of your AWS Cloud Cost connections into your project's DAG:

1. For each source provided to the `aws_cloud_cost_sources` variable, you must now add a unique `name` attribute. This can be any name, so long as it is unique and matches the `source.name` you define in the following step.

```yml
# dbt_project.yml

vars:
  aws_cloud_cost_sources:
    - database: source_databse_name
      schema: source_schema_name
      table: source_table_name
      name: unique_source_name # NOW REQUIRED - can choose any name so long as it is unique

    - database: 'my-db-example'
      schema: aws_cost_schema_example
      table: report_table_example
      name: my_aws_cost_report_source

    # include as many sources as you'd like
```

2. Define each source provided to the `aws_cloud_cost_sources` variable in a `.yml` file in your root project's `models/` pathway. Utilize the following template for the `source`-level configurations, and, **most importantly**, copy and paste the table and column-level definitions:

<details>
<summary><i>Expand for source template</i></summary>

```yml
# a .yml file in your root project
sources:
  - name: <name> # Must map onto name in var(aws_cloud_cost_sources) you added in the previous step
    schema: <schema_name> # Must map onto schema in var(aws_cloud_cost_sources)
    database: <database_name> # Must map onto database in var(aws_cloud_cost_sources)
    loader: fivetran
    loaded_at_field: _fivetran_synced

    tables:
      - name: <table_name_as_it_appears_in_warehouse> # Must map onto table in var(aws_cloud_cost_sources)
        description: '{{ doc("aws_cloud_cost_report") }}' # Your projecy will inherit docs blocks defined by this package
        columns: &aws_report_columns # Can use columns: *aws_report yaml anchor in subsequent sources
          - name: _file
            description: '{{ doc("_file") }}'
          - name: _line
            description: '{{ doc("_line") }}'
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: _modified
            description: '{{ doc("_modified") }}'
          - name: bill_bill_type
            description: '{{ doc("bill_bill_type") }}'
          - name: bill_billing_entity
            description: '{{ doc("bill_billing_entity") }}'
          - name: bill_billing_period_end_date
            description: '{{ doc("bill_billing_period_end_date") }}'
          - name: bill_billing_period_start_date
            description: '{{ doc("bill_billing_period_start_date") }}'
          - name: bill_invoice_id
            description: '{{ doc("bill_invoice_id") }}'
          - name: bill_invoicing_entity
            description: '{{ doc("bill_invoicing_entity") }}'
          - name: bill_payer_account_id
            description: '{{ doc("bill_payer_account_id") }}'
          - name: identity_line_item_id
            description: '{{ doc("identity_line_item_id") }}'
          - name: identity_time_interval
            description: '{{ doc("identity_time_interval") }}'
          - name: line_item_availability_zone
            description: '{{ doc("line_item_availability_zone") }}'
          - name: line_item_blended_cost
            description: '{{ doc("line_item_blended_cost") }}'
          - name: line_item_blended_rate
            description: '{{ doc("line_item_blended_rate") }}'
          - name: line_item_currency_code
            description: '{{ doc("line_item_currency_code") }}'
          - name: line_item_legal_entity
            description: '{{ doc("line_item_legal_entity") }}'
          - name: line_item_line_item_description
            description: '{{ doc("line_item_line_item_description") }}'
          - name: line_item_line_item_type
            description: '{{ doc("line_item_line_item_type") }}'
          - name: line_item_normalization_factor
            description: '{{ doc("line_item_normalization_factor") }}'
          - name: line_item_normalized_usage_amount
            description: '{{ doc("line_item_normalized_usage_amount") }}'
          - name: line_item_operation
            description: '{{ doc("line_item_operation") }}'
          - name: line_item_product_code
            description: '{{ doc("line_item_product_code") }}'
          - name: line_item_resource_id
            description: '{{ doc("line_item_resource_id") }}'
          - name: line_item_tax_type
            description: '{{ doc("line_item_tax_type") }}'
          - name: line_item_unblended_cost
            description: '{{ doc("line_item_unblended_cost") }}'
          - name: line_item_unblended_rate
            description: '{{ doc("line_item_unblended_rate") }}'
          - name: line_item_usage_account_id
            description: '{{ doc("line_item_usage_account_id") }}'
          - name: line_item_usage_amount
            description: '{{ doc("line_item_usage_amount") }}'
          - name: line_item_usage_end_date
            description: '{{ doc("line_item_usage_end_date") }}'
          - name: line_item_usage_start_date
            description: '{{ doc("line_item_usage_start_date") }}'
          - name: line_item_usage_type
            description: '{{ doc("line_item_usage_type") }}'
          - name: pricing_currency
            description: '{{ doc("pricing_currency") }}'
          - name: pricing_lease_contract_length
            description: '{{ doc("pricing_lease_contract_length") }}'
          - name: pricing_offering_class
            description: '{{ doc("pricing_offering_class") }}'
          - name: pricing_public_on_demand_cost
            description: '{{ doc("pricing_public_on_demand_cost") }}'
          - name: pricing_public_on_demand_rate
            description: '{{ doc("pricing_public_on_demand_rate") }}'
          - name: pricing_purchase_option
            description: '{{ doc("pricing_purchase_option") }}'
          - name: pricing_rate_code
            description: '{{ doc("pricing_rate_code") }}'
          - name: pricing_rate_id
            description: '{{ doc("pricing_rate_id") }}'
          - name: pricing_term
            description: '{{ doc("pricing_term") }}'
          - name: pricing_unit
            description: '{{ doc("pricing_unit") }}'
          - name: product_fee_code
            description: '{{ doc("product_fee_code") }}'
          - name: product_fee_description
            description: '{{ doc("product_fee_description") }}'
          - name: product_from_location
            description: '{{ doc("product_from_location") }}'
          - name: product_from_location_type
            description: '{{ doc("product_from_location_type") }}'
          - name: product_from_region_code
            description: '{{ doc("product_from_region_code") }}'
          - name: product_instance_family
            description: '{{ doc("product_instance_family") }}'
          - name: product_instance_type
            description: '{{ doc("product_instance_type") }}'
          - name: product_location
            description: '{{ doc("product_location") }}'
          - name: product_location_type
            description: '{{ doc("product_location_type") }}'
          - name: product_operation
            description: '{{ doc("product_operation") }}'
          - name: product_pricing_unit
            description: '{{ doc("product_pricing_unit") }}'
          - name: product_product_family
            description: '{{ doc("product_product_family") }}'
          - name: product_product_name
            description: '{{ doc("product_product_name") }}'
          - name: product_region_code
            description: '{{ doc("product_region_code") }}'
          - name: product_servicecode
            description: '{{ doc("product_servicecode") }}'
          - name: product_sku
            description: '{{ doc("product_sku") }}'
          - name: product_to_location
            description: '{{ doc("product_to_location") }}'
          - name: product_to_location_type
            description: '{{ doc("product_to_location_type") }}'
          - name: product_to_region_code
            description: '{{ doc("product_to_region_code") }}'
          - name: product_usagetype
            description: '{{ doc("product_usagetype") }}'
          - name: reservation_amortized_upfront_fee_for_billing_period
            description: '{{ doc("reservation_amortized_upfront_fee_for_billing_period") }}'
          - name: reservation_end_time
            description: '{{ doc("reservation_end_time") }}'
          - name: reservation_modification_status
            description: '{{ doc("reservation_modification_status") }}'
          - name: reservation_normalized_units_per_reservation
            description: '{{ doc("reservation_normalized_units_per_reservation") }}'
          - name: reservation_number_of_reservations
            description: '{{ doc("reservation_number_of_reservations") }}'
          - name: reservation_reservation_arn
            description: '{{ doc("reservation_reservation_arn") }}'
          - name: reservation_start_time
            description: '{{ doc("reservation_start_time") }}'
          - name: reservation_subscription_id
            description: '{{ doc("reservation_subscription_id") }}'
          - name: reservation_total_reserved_normalized_units
            description: '{{ doc("reservation_total_reserved_normalized_units") }}'
          - name: reservation_total_reserved_units
            description: '{{ doc("reservation_total_reserved_units") }}'
          - name: reservation_units_per_reservation
            description: '{{ doc("reservation_units_per_reservation") }}'
          - name: reservation_unused_amortized_upfront_fee_for_billing_period
            description: '{{ doc("reservation_unused_amortized_upfront_fee_for_billing_period") }}'
          - name: reservation_unused_normalized_unit_quantity
            description: '{{ doc("reservation_unused_normalized_unit_quantity") }}'
          - name: reservation_unused_quantity
            description: '{{ doc("reservation_unused_quantity") }}'
          - name: reservation_unused_recurring_fee
            description: '{{ doc("reservation_unused_recurring_fee") }}'
          - name: reservation_upfront_value
            description: '{{ doc("reservation_upfront_value") }}'
          - name: savings_plan_end_time
            description: '{{ doc("savings_plan_end_time") }}'
          - name: savings_plan_offering_type
            description: '{{ doc("savings_plan_offering_type") }}'
          - name: savings_plan_payment_option
            description: '{{ doc("savings_plan_payment_option") }}'
          - name: savings_plan_purchase_term
            description: '{{ doc("savings_plan_purchase_term") }}'
          - name: savings_plan_region
            description: '{{ doc("savings_plan_region") }}'
          - name: savings_plan_savings_plan_arn
            description: '{{ doc("savings_plan_savings_plan_arn") }}'
          - name: savings_plan_savings_plan_effective_cost
            description: '{{ doc("savings_plan_savings_plan_effective_cost") }}'
          - name: savings_plan_savings_plan_rate
            description: '{{ doc("savings_plan_savings_plan_rate") }}'
          - name: savings_plan_start_time
            description: '{{ doc("savings_plan_start_time") }}'
          - name: bill_payer_account_name
            description: '{{ doc("bill_payer_account_name") }}'
          - name: product
            description: '{{ doc("product") }}'
          - name: discount
            description: '{{ doc("discount") }}'
          - name: resource_tags
            description: '{{ doc("resource_tags") }}'
          - name: cost_category
            description: '{{ doc("cost_category") }}'
          - name: line_item_usage_account_name
            description: '{{ doc("line_item_usage_account_name") }}'
          - name: reservation_reservation_a_r_n
            description: '{{ doc("reservation_reservation_a_r_n") }}'
          - name: reservation_recurring_fee_for_usage
            description: '{{ doc("reservation_recurring_fee_for_usage") }}'
          - name: savings_plan_recurring_commitment_for_billing_period
            description: '{{ doc("savings_plan_recurring_commitment_for_billing_period") }}'
          - name: savings_plan_used_commitment
            description: '{{ doc("savings_plan_used_commitment") }}'
          - name: reservation_amortized_upfront_cost_for_usage
            description: '{{ doc("reservation_amortized_upfront_cost_for_usage") }}'
          - name: reservation_effective_cost
            description: '{{ doc("reservation_effective_cost") }}'
          - name: savings_plan_amortized_upfront_commitment_for_billing_period
            description: '{{ doc("savings_plan_amortized_upfront_commitment_for_billing_period") }}'
          - name: savings_plan_total_commitment_to_date
            description: '{{ doc("savings_plan_total_commitment_to_date") }}'
```

</details>

3. Set the `has_defined_sources` variable (scoped to the `aws_cloud_cost` package) to `True`, like such:

```yml
# dbt_project.yml
vars:
  aws_cloud_cost:
    has_defined_sources: true
```

### (Optional) Additional configurations

##### Limit Date Range
Although the package transforms the latest version of each report, your AWS Cost & Usage Report data may still be quite large. In order to avoid unnecessary compute and storage costs, we have added a minimum (INCLUSIVE) **start date** variable that can be used to limit the data's date range.

By default, the package will look at data as far back as you have it. To adjust this, configure the following variable in your `dbt_project.yml` to be the first date you want *included*:
```yml
# dbt_project.yml

vars:
    aws_cloud_cost_start_date: 'YYYY-MM-DD' # default value: '1970-01-01' 
```

> Note for BigQuery users: This filter applies a full table scan and may therefore not actually mitigate your compute costs. We have applied [partitions](https://docs.getdbt.com/reference/resource-configs/bigquery-configs#partition-clause) to each end model, but you may want to consider applying pre-package transformations (partitions, filters, etc.) to streamline the amount of data processed by the package.
>
> Please create an [issue](https://github.com/fivetran/dbt_aws_cloud_cost/issues) if you'd like to see support for incremental materializations.

##### Passing Through Additional Fields
This package includes all source columns defined in the macros folder. You can add more columns to the `aws_cloud_cost__daily_overview` model using the `aws_cloud_cost_report_pass_through_columns` variable. This variable allows for custom or otherwise not included fields to be included, aliased (`alias`), and casted (`transform_sql`) if desired (but not required). Datatype casting is configured via a sql snippet within the `transform_sql` key. You may add the desired sql while omitting the `as field_name` at the end and your custom pass-though fields will be casted accordingly.

Use the below format for declaring extra fields to include:

```yml
# dbt_project.yml

vars:
  aws_cloud_cost_report_pass_through_columns: # will be included in aws_cloud_cost__daily_overview model
    - name: "that_field"
      alias: "renamed_to_this_field"
      transform_sql: "cast(renamed_to_this_field as string)"
    - name: "this_field"
    - name: "old_name"
      alias: "new_name"
```

These fields will be included in the `aws_cloud_cost__daily_overview` model and part of its composite hashed `unique_key`.

> Please create an [issue](https://github.com/fivetran/dbt_aws_cloud_cost/issues) if you'd like to see passthrough column support for the `aws_cloud_cost__daily_product_report` or `aws_cloud_cost__daily_instance_report` models.

##### Changing the Build Schema
By default this package will build the AWS Cloud Cost staging models within a schema titled (<target_schema> + `_stg_aws_cloud_cost`) and the AWS Cloud Cost final models within a schema titled (<target_schema> + `_aws_cloud_cost`) in your target database. If this is not where you would like your modeled AWS Cloud Cost data to be written to, add the following configuration to your `dbt_project.yml` file:

```yml
# dbt_project.yml

models:
  aws_cloud_cost:
    +schema: my_new_schema_name # leave blank for just the target_schema
    staging:
        +schema: my_new_schema_name # leave blank for just the target_schema
```
</details>

### (Optional) Orchestrate your models with Fivetran Transformations for dbt Core™
<details><summary>Expand for details</summary>
<br>

Fivetran offers the ability for you to orchestrate your dbt project through [Fivetran Transformations for dbt Core™](https://fivetran.com/docs/transformations/dbt#transformationsfordbtcore). Learn how to set up your project for orchestration through Fivetran in our [Transformations for dbt Core setup guides](https://fivetran.com/docs/transformations/dbt/setup-guide#transformationsfordbtcoresetupguide).
</details>

### Does this package have dependencies?
This dbt package is dependent on the following dbt packages. These dependencies are installed by default within this package. For more information on the following packages, refer to the [dbt hub](https://hub.getdbt.com/) site.
> IMPORTANT: If you have any of these dependent packages in your own `packages.yml` file, we highly recommend that you remove them from your root `packages.yml` to avoid package version conflicts.

```yml
packages:
    - package: fivetran/fivetran_utils
      version: [">=0.4.0", "<0.5.0"]

    - package: dbt-labs/dbt_utils
      version: [">=1.0.0", "<2.0.0"]
```

<!--section="aws-cloud-cost_maintenance"-->
## How is this package maintained and can I contribute?

### Package Maintenance
The Fivetran team maintaining this package only maintains the [latest version](https://hub.getdbt.com/fivetran/aws_cloud_cost/latest/) of the package. We highly recommend you stay consistent with the latest version of the package and refer to the [CHANGELOG](https://github.com/fivetran/dbt_aws_cloud_cost/blob/main/CHANGELOG.md) and release notes for more information on changes across versions.

### Contributions
A small team of analytics engineers at Fivetran develops these dbt packages. However, the packages are made better by community contributions.

We highly encourage and welcome contributions to this package. Learn how to contribute to a package in dbt's [Contributing to an external dbt package article](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657).

<!--section-end-->

## Are there any resources available?
- If you have questions or want to reach out for help, see the [GitHub Issue](https://github.com/fivetran/dbt_aws_cloud_cost/issues/new/choose) section to find the right avenue of support for you.
- If you would like to provide feedback to the dbt package team at Fivetran or would like to request a new dbt package, fill out our [Feedback Form](https://www.surveymonkey.com/r/DQ7K7WW).
