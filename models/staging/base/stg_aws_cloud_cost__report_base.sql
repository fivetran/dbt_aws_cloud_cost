{{
    fivetran_utils.union_data(
        table_identifier='report', 
        database_variable='aws_cloud_cost_database', 
        schema_variable='aws_cloud_cost_schema', 
        default_database=target.database,
        default_schema='aws_cloud_cost',
        default_variable='aws_cloud_cost_report',
        union_schema_variable='aws_cloud_cost_union_schemas',
        union_database_variable='aws_cloud_cost_union_databases'
    )
}}

{# {{
    union_aws_cost_report_connections(
        connection_dictionary=var('aws_cloud_cost_sources'),
        single_schema=var('aws_cloud_cost_schema', 'aws_cloud_cost'),
        single_database=var('aws_cloud_cost_schema', target.database),
        single_table_identifier=var("aws_cloud_cost_report_identifier", "aws_cost_report")
    )
}} #}
