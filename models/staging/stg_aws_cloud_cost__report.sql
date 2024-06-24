
with base as (

    select * 
    from {{ ref('stg_aws_cloud_cost__report_base') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_aws_cloud_cost__report_base')),
                staging_columns=get_aws_cloud_cost_report_columns()
            )
        }}
        {{ fivetran_utils.source_relation(
            union_schema_variable='aws_cloud_cost_union_schemas', 
            union_database_variable='aws_cloud_cost_union_databases') 
        }}
    from base
),

final as (
    
    select 
        source_relation, 
        _file,
        coalesce(
            {{ dbt.split_part(string_text='_file', delimiter_text="'/data'", part_number=1) }},
            REGEXP_EXTRACT(_file, r'/([^/]+)/')) as report,
        {# _fivetran_synced, #}
        _line,
        _modified,
        row_number() over (partition by bill_billing_period_start_date, _line, source_relation order by _modified desc) = 1 as is_latest_file_version,
        
        bill_bill_type, 
        bill_billing_entity,
        bill_billing_period_start_date,
        bill_billing_period_end_date,
        bill_invoice_id,
        bill_invoicing_entity,
        bill_payer_account_id,
        bill_payer_account_name,

        identity_line_item_id, -- supposed to be PK within a report
        identity_time_interval, -- doesn't actually line up with line_item_usage_start_date and line_item_usage_end_date
        {{ dbt.split_part(string_text='identity_time_interval', delimiter_text="'/'", part_number=1) }} as identity_time_interval_start,
        {{ dbt.split_part(string_text='identity_time_interval', delimiter_text="'/'", part_number=2) }} as identity_time_interval_end,
        
        line_item_availability_zone,
        line_item_blended_cost,
        line_item_blended_rate,
        line_item_currency_code,
        line_item_normalization_factor,
        line_item_normalized_usage_amount,

        line_item_line_item_description,
        line_item_line_item_type,
        line_item_operation,
        line_item_product_code,
        line_item_resource_id, -- null unless you've enabled `INCLUDE RESOURCES` in your AWS CUR configuration
        line_item_tax_type,
        line_item_unblended_cost,
        line_item_unblended_rate,
        line_item_usage_account_id,
        line_item_usage_account_name,
        line_item_usage_amount,
        line_item_usage_end_date,
        line_item_usage_start_date,
        line_item_usage_type,

        pricing_currency,
        pricing_public_on_demand_cost, -- sum 
        pricing_public_on_demand_rate, -- average
        pricing_purchase_option,
        pricing_term,
        pricing_unit,

        product_fee_code, -- similar to line_item_description
        product_fee_description,

        -- info about product
        product_operation,
        product_product_family,
        product_servicecode as product_service_code,

        -- for s3 buckets
        product_location,
        product_location_type,
        product_region_code,

        -- for data movement
        product_from_location,
        product_from_location_type,
        product_from_region_code,
        product_to_location,
        product_to_location_type,
        product_to_region_code,

        -- has size 
        product_instance_family,
        product_instance_type,

        -- default: only include reservation + savings plan numeric fields, dimensions can be added via passthroughs
        reservation_amortized_upfront_cost_for_usage,
        reservation_amortized_upfront_fee_for_billing_period,
        reservation_effective_cost,
        reservation_number_of_reservations,
        reservation_normalized_units_per_reservation,
        reservation_units_per_reservation,
        reservation_total_reserved_normalized_units,
        reservation_total_reserved_units,
        reservation_recurring_fee_for_usage,
        reservation_unused_amortized_upfront_fee_for_billing_period,
        reservation_unused_normalized_unit_quantity,
        reservation_unused_quantity,
        reservation_unused_recurring_fee,
        reservation_upfront_value,
        savings_plan_amortized_upfront_commitment_for_billing_period,
        savings_plan_recurring_commitment_for_billing_period,
        savings_plan_savings_plan_effective_cost,
        savings_plan_savings_plan_rate,
        savings_plan_total_commitment_to_date,
        savings_plan_used_commitment 

        {{ fivetran_utils.fill_pass_through_columns('aws_cloud_cost_report_pass_through_columns') }}

    from fields
)

select *
from final
where is_latest_file_version
