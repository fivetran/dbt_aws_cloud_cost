<!--section="aws-cloud-cost_transformation_model"-->
# AWS Cloud Cost dbt Package

This dbt package transforms data from Fivetran's AWS Cloud Cost connector into analytics-ready tables.

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
    version: [">=0.4.0", "<0.5.0"] # we recommend using ranges to capture non-breaking changes automatically
```

##### Databricks dispatch configuration
If you are using a Databricks destination with this package, you must add the following (or a variation of the following) dispatch configuration within your `dbt_project.yml`. This is required in order for the package to accurately search for macros within the `dbt-labs/spark_utils` then the `dbt-labs/dbt_utils` packages respectively.
```yml
dispatch:
  - macro_namespace: dbt_utils
    search_order: ['spark_utils', 'dbt_utils']
```

### Define database and schema variables
#### Option A: Single connection
By default, this package runs using your destination and the `aws_cloud_cost` schema. If this is not where your AWS Cloud Cost data is (for example, if your AWS Cloud Cost schema is named `aws_cloud_cost_fivetran`), add the following configuration to your root `dbt_project.yml` file:

```yml
vars:
    aws_cloud_cost_database: your_destination_name
    aws_cloud_cost_schema: your_schema_name
```

#### Option B: Union multiple connections
If you have multiple AWS Cloud Cost connections in Fivetran and would like to use this package on all of them simultaneously, we have provided functionality to do so. For each source table, the package will union all of the data together and pass the unioned table into the transformations. The `source_relation` column in each model indicates the origin of each record.

To use this functionality, you will need to set the `aws_cloud_cost_sources` variable in your root `dbt_project.yml` file:

```yml
# dbt_project.yml

vars:
  aws_cloud_cost:
    aws_cloud_cost_sources:
      - database: connection_1_destination_name # Required
        schema: connection_1_schema_name # Required
        name: connection_1_source_name # Required only if following the step in the following subsection

      - database: connection_2_destination_name
        schema: connection_2_schema_name
        name: connection_2_source_name
```

#### Optional: Incorporate unioned sources into DAG

If you use [Fivetran Transformations for dbt Core™](https://fivetran.com/docs/transformations/dbt#transformationsfordbtcore) and are unioning multiple AWS Cloud Cost connections, you can define your sources in a property `.yml` file, [using this as a template](https://github.com/fivetran/dbt_aws_cloud_cost/blob/main/models/staging/src_aws_cloud_cost.yml). Set the variable `has_defined_sources: true` under the AWS Cloud Cost namespace in your `dbt_project.yml`. Otherwise, your AWS Cloud Cost connections won't appear in your DAG. See the `union_connections` macro [documentation](https://github.com/fivetran/dbt_fivetran_utils/tree/releases/v0.4.latest#optional-union-connections-defined-sources-configuration) for full configuration details.

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

##### Source casing for case-sensitive destinations
By default, the package applies case-insensitive comparisons when resolving `source_relation` values. If your destination is case-sensitive and you want downstream transformations to respect the exact casing of your source database and schema names, set the following variable:

```yml
vars:
    fivetran_using_source_casing: true
```

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