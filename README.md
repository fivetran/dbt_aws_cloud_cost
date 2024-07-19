<p align="center">
    <a alt="License"
        href="https://github.com/fivetran/dbt_aws_cloud_cost/blob/main/LICENSE">
        <img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg" /></a>
    <a alt="dbt-core">
        <img src="https://img.shields.io/badge/dbt_Core™_version->=1.3.0_<2.0.0-orange.svg" /></a>
    <a alt="Maintained?">
        <img src="https://img.shields.io/badge/Maintained%3F-yes-green.svg" /></a>
    <a alt="PRs">
        <img src="https://img.shields.io/badge/Contributions-welcome-blueviolet" /></a>
</p>

# 🚧 **WIP** 🚧

# AWS Cloud Cost dbt Package ([Docs](https://fivetran.github.io/dbt_aws_cloud_cost/))

# 📣 What does this dbt package do?

This package models AWS Cloud Cost data from [Fivetran's connector](https://fivetran.com/docs/applications/aws_cloud_cost). It uses data in the format described by [this ERD](https://fivetran.com/docs/applications/aws_cloud_cost#schemainformation).

The main focus of the package is to transform the core object tables into analytics-ready models, including:
<!--section="aws_cloud_cost_model"-->
  - Materializes [AWS Cloud Cost staging tables](https://fivetran.github.io/dbt_aws_cloud_cost/#!/overview/aws_cloud_cost/models/?g_v=1) which leverage data in the format described by the [AWS Cost & Usage Report](https://docs.aws.amazon.com/cur/latest/userguide/table-dictionary-cur2.html). These staging tables clean, test, and prepare your AWS Cloud Cost data from [Fivetran's connector](https://fivetran.com/docs/connectors/applications/aws-cost-report) for analysis by doing the following:
  - Name columns for consistency across all packages and for easier analysis
      - Primary keys are renamed from `id` to `<table name>_id`.
      - Redundant column names are shortened (ex: `bill_bill_type` -> `bill_type`).
  - Adds column-level testing where applicable. For example, all primary keys are tested for uniqueness and non-null values.
  - Generates a comprehensive data dictionary of your AWS Cloud Cost data through the [dbt docs site](https://fivetran.github.io/dbt_aws_cloud_cost/).
  - Takes latest version of billing month report exports.

> This package does not apply freshness tests.

<!--section="aws_cloud_cost_model"-->
The following table provides a detailed list of all models materialized within this package by default. 
> TIP: See more details about these models in the package's [dbt docs site](https://fivetran.github.io/dbt_aws_cloud_cost/#!/overview/aws_cloud_cost).

| **model**                 | **description**                                                                                                    |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| [aws_cloud_cost__overview](https://github.com/fivetran/dbt_aws_cloud_cost/blob/main/models/aws_cloud_cost__overview.sql)  | Model description   |
<!--section-end-->

# 🎯 How do I use the dbt package?

## Step 1: Prerequisites
To use this dbt package, you must have the following:

- At least one Fivetran AWS Cloud Cost connector syncing data into your destination.
- A **BigQuery**, **Snowflake**, **Redshift**, **Databricks**, or **PostgreSQL** destination.

### Databricks dispatch configuration
If you are using a Databricks destination with this package, you must add the following (or a variation of the following) dispatch configuration within your `dbt_project.yml`. This is required in order for the package to accurately search for macros within the `dbt-labs/spark_utils` then the `dbt-labs/dbt_utils` packages respectively.
```yml
dispatch:
  - macro_namespace: dbt_utils
    search_order: ['spark_utils', 'dbt_utils']
```

## Step 2: Install the package
Include the following AWS Cloud Cost package version in your `packages.yml` file:
> TIP: Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.
```yml
packages:
  - package: fivetran/aws_cloud_cost
    version: [">=0.1.0", "<0.2.0"] # we recommend using ranges to capture non-breaking changes automatically
```

## Step 3: Define database and schema variables
### Single connector
By default, this package runs using your destination and the `aws_cloud_cost` schema. If this is not where your AWS Cloud Cost data is (for example, if your AWS Cloud Cost schema is named `aws_cloud_cost_fivetran`), add the following configuration to your root `dbt_project.yml` file:

```yml
# dbt_project.yml

vars:
    aws_cloud_cost_database: your_database_name
    aws_cloud_cost_schema: your_schema_name
```

### Union multiple connectors
If you have multiple AWS Cloud Cost connectors in Fivetran and would like to use this package on all of them simultaneously, we have provided functionality to do so. The package will union all of the data together and pass the unioned table into the transformations. You will be able to see which source it came from in the `source_relation` column of each model. To use this functionality, you will need to set either the `aws_cloud_cost_union_schemas` OR `aws_cloud_cost_union_databases` variables (cannot do both) in your root `dbt_project.yml` file:

```yml
# dbt_project.yml

vars:
    aws_cloud_cost_union_schemas: ['aws_cloud_cost_usa','aws_cloud_cost_canada'] # use this if the data is in different schemas/datasets of the same database/project
    aws_cloud_cost_union_databases: ['aws_cloud_cost_usa','aws_cloud_cost_canada'] # use this if the data is in different databases/projects but uses the same schema name
```

Please be aware that the native `source.yml` connection set up in the package will not function when the union schema/database feature is utilized. Although the data will be correctly combined, you will not observe the sources linked to the package models in the Directed Acyclic Graph (DAG). This happens because the package includes only one defined `source.yml`.

To connect your multiple schema/database sources to the package models, follow the steps outlined in the [Union Data Defined Sources Configuration](https://github.com/fivetran/dbt_fivetran_utils/tree/releases/v0.4.latest#union_data-source) section of the Fivetran Utils documentation for the union_data macro. This will ensure a proper configuration and correct visualization of connections in the DAG.


## Step 4: Define Cost & Usage Report source table
By default, this package assumes your AWS Cost & Usage Report lives in a source table called `aws_cloud_cost_report`. In the very likely case that this is not what your table is called, configure the following variable in your `dbt_project.yml`.

```yml
# dbt_project.yml

vars:
    aws_cloud_cost_report_identifier: your_table_name 
```

> Note: If you are unioning multiple connectors, they must have the **same table name**. If this is not the case, we recommend configuring one AWS Data Export to include all of your sources and pipe the report data to a single Fivetran connector.

## (Optional) Step 5: Additional configurations

### Limit Date Range 
<TO FILL IN AFTER CONFIRMING WE WANNA DO THIS.>

### Passing Through Additional Fields
This package includes all source columns defined in the macros folder. You can add more columns using the `aws_cloud_cost_report_pass_through_columns` variable. This variables allow for custom or otherwise not included fields to be included, aliased (`alias`), and casted (`transform_sql`) if desired (but not required). Datatype casting is configured via a sql snippet within the `transform_sql` key. You may add the desired sql while omitting the `as field_name` at the end and your custom pass-though fields will be casted accordingly. Use the below format for declaring extra fields to include:

```yml
# dbt_project.yml

vars:
  aws_cloud_cost_report_pass_through_columns:
    - name: "that_field"
      alias: "renamed_to_this_field"
      transform_sql: "cast(renamed_to_this_field as string)"
  aws_cloud_cost_report_pass_through_columns:
    - name: "this_field"
  aws_cloud_cost_report_pass_through_columns:
    - name: "old_name"
      alias: "new_name"
```

> Please create an [issue](https://github.com/fivetran/dbt_aws_cloud_cost/issues) if you'd like to see passthrough column support for other tables in the Qualtrics schema.

### Changing the Build Schema
By default this package will build the AWS Cloud Cost staging models within a schema titled (<target_schema> + `_stg_aws_cloud_cost`) and the AWS Cloud Cost final models within a schema titled (<target_schema> + `_aws_cloud_cost`) in your target database. If this is not where you would like your modeled qualtrics data to be written to, add the following configuration to your `dbt_project.yml` file:

```yml
# dbt_project.yml

models:
  aws_cloud_cost:
    +schema: my_new_schema_name # leave blank for just the target_schema
    staging:
        +schema: my_new_schema_name # leave blank for just the target_schema
```
</details>


## (Optional) Step 6: Orchestrate your models with Fivetran Transformations for dbt Core™
<details><summary>Expand for details</summary>
<br>
    
Fivetran offers the ability for you to orchestrate your dbt project through [Fivetran Transformations for dbt Core™](https://fivetran.com/docs/transformations/dbt). Learn how to set up your project for orchestration through Fivetran in our [Transformations for dbt Core setup guides](https://fivetran.com/docs/transformations/dbt#setupguide).
</details>


# 🔍 Does this package have dependencies?
This dbt package is dependent on the following dbt packages. Please be aware that these dependencies are installed by default within this package. For more information on the following packages, refer to the [dbt hub](https://hub.getdbt.com/) site.
> IMPORTANT: If you have any of these dependent packages in your own `packages.yml` file, we highly recommend that you remove them from your root `packages.yml` to avoid package version conflicts.
    
```yml
packages:
    - package: fivetran/fivetran_utils
      version: [">=0.4.0", "<0.5.0"]

    - package: dbt-labs/dbt_utils
      version: [">=1.0.0", "<2.0.0"]
```

# 🙌 How is this package maintained and can I contribute?
## Package Maintenance
The Fivetran team maintaining this package _only_ maintains the latest version of the package. We highly recommend you stay consistent with the [latest version](https://hub.getdbt.com/fivetran/aws_cloud_cost/latest/) of the package and refer to the [CHANGELOG](https://github.com/fivetran/dbt_aws_cloud_cost/blob/main/CHANGELOG.md) and release notes for more information on changes across versions.

## Contributions
A small team of analytics engineers at Fivetran develops these dbt packages. However, the packages are made better by community contributions! 

We highly encourage and welcome contributions to this package. Check out [this dbt Discourse article](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657) on the best workflow for contributing to a package!

# 🏪 Are there any resources available?
- If you have questions or want to reach out for help, please refer to the [GitHub Issue](https://github.com/fivetran/dbt_aws_cloud_cost/issues/new/choose) section to find the right avenue of support for you.
- If you would like to provide feedback to the dbt package team at Fivetran or would like to request a new dbt package, fill out our [Feedback Form](https://www.surveymonkey.com/r/DQ7K7WW).