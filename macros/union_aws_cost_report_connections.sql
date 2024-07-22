{% macro union_aws_cost_report_connections(connection_dictionary, single_schema, single_database, single_table_identifier) %}

{% if connection_dictionary %}
{# For unioning #}
    {%- set relations = [] -%}
    {%- for connection in connection_dictionary -%}

        {%- set relation=adapter.get_relation(
            database=connection.database,
            schema=connection.schema,
            identifier=connection.table) -%}

        {%- if relation is not none -%}
            {%- do relations.append(relation) -%}
        {%- endif -%}

    {%- endfor -%}

    {%- if relations != [] -%}
        {{ aws_cloud_cost_union_relations(relations) }}
    {%- else -%}
        {% if execute and not var('fivetran__remove_empty_table_warnings', false) -%}
        {{ exceptions.warn("\n\nPlease be aware: The AWS Cost Report table was not found in your schema(s). The Fivetran Data Model will create a completely empty staging model as to not break downstream transformations. To turn off these warnings, set the `fivetran__remove_empty_table_warnings` variable to TRUE (see https://github.com/fivetran/dbt_fivetran_utils/tree/releases/v0.4.latest#union_data-source for details).\n") }}
        {% endif -%}
    select 
        cast(null as {{ dbt.type_string() }}) as _dbt_source_relation
    limit 0
    {%- endif -%}

{% else %}
{# Not unioning #}
    {%- set relation.value=adapter.get_relation(
        database=single_database,
        schema=single_schema,
        identifier=single_table_identifier) -%}

    {%- if relation.value is not none -%}
        select
            {{ dbt_utils.star(from=relation.value) }}
        from {{ relation.value }} as {{ single_table_identifier }}_table
    
    {% else %}
        {% if execute and not var('fivetran__remove_empty_table_warnings', false) -%}
            {{ exceptions.warn("\n\nPlease be aware: The AWS Cost Report table was not found in your schema. The Fivetran Data Model will create a completely empty staging model as to not break downstream transformations. To turn off these warnings, set the `fivetran__remove_empty_table_warnings` variable to TRUE (see https://github.com/fivetran/dbt_fivetran_utils/tree/releases/v0.4.latest#union_data-source for details).\n") }}
        {% endif -%}
        
        select 
            cast(null as {{ dbt.type_string() }}) as _dbt_source_relation
        limit 0
    {%- endif -%}
{% endif -%}

{% endmacro %}