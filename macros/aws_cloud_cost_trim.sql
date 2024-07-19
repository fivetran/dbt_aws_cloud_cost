{% macro aws_cloud_cost_trim(string) -%}

{{ adapter.dispatch('aws_cloud_cost_trim', 'aws_cloud_cost') (string) }}

{%- endmacro %}


{% macro default__aws_cloud_cost_trim(string) %}

TRIM(BOTH '/' FROM ({{ string }}))

{%- endmacro %}


{% macro bigquery__aws_cloud_cost_trim(string) %}

TRIM('/', ({{ string }}))

{%- endmacro %}

{% macro snowflake__aws_cloud_cost_trim(string) %}

TRIM('/', ({{ string }}))

{%- endmacro %}