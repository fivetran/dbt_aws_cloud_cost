{{
    aws_cloud_cost.union_aws_cost_report_connections(
        connection_dictionary=var('aws_cloud_cost_sources'),
        single_source_name='aws_cloud_cost',
        single_table_name='report'
    )
}}