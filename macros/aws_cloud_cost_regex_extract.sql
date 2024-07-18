{% macro aws_cloud_cost_regex_extract(string) -%}

{{ adapter.dispatch('aws_cloud_cost_regex_extract', 'aws_cloud_cost') (string) }}

{%- endmacro %}


{% macro default__aws_cloud_cost_regex_extract(string) %}

{{ exceptions.raise_compiler_error("Adapter not supported. This Model only supports BigQuery, Snowflake, Redshift, Postgres, Databricks, and Spark.") }}

{%- endmacro %}


{% macro bigquery__aws_cloud_cost_regex_extract(string) %}

coalesce(REGEXP_EXTRACT(_file, r'^([^\/]+\/[^\/]+)'), REGEXP_EXTRACT(_file, r'\/([^\/]+)\/'))

{%- endmacro %}


{% macro snowflake__aws_cloud_cost_regex_extract(string) %}

coalesce(REGEXP_SUBSTR({{ string }}, '^([^/]+/[^/]+)', 1, 1, NULL, 1), REGEXP_SUBSTR(_file, '/([^/]+)/', 1, 1, NULL, 1))

{%- endmacro %}


{% macro postgres__aws_cloud_cost_regex_extract(string) %}

coalesce((REGEXP_MATCH({{ string }}, '^([^\/]+\/[^\/]+)'))[1], (REGEXP_MATCH({{ string }}, '\/([^\/]+)\/'))[1])

{%- endmacro %}

{% macro redshift__aws_cloud_cost_regex_extract(string) %}

coalesce(REGEXP_SUBSTR({{ string }}, '^([^/]+/[^/]+)', 1), REGEXP_SUBSTR({{ string }}, '/([^/]+)/', 1, 1, 'e'))

{%- endmacro %}


{% macro spark__aws_cloud_cost_regex_extract(string) %}

coalesce(regexp_extract({{ string }}, '^([^\/]+\/[^\/]+)', 1), regexp_extract({{ string }}, '\/([^\/]+)\/', 1))

{%- endmacro %}