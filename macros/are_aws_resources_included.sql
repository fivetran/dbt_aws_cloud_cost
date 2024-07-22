{# {% macro are_aws_resources_included %}

    {%- set first_date_query %}
        select max(resource_id) from {{ source('aws_cloud_cost', 'report') }}
    {% endset -%} #}