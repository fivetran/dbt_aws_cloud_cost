
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
        {{ aws_cloud_cost_trim( dbt.concat([ dbt.split_part('_file', "'/'", 1), "'/'", dbt.split_part('_file', "'/'", 2) ]) ) }} as report,
        _line,
        _modified,
        max(_modified) over(partition by bill_billing_period_start_date, source_relation) = _modified as is_latest_file_version,
        bill_bill_type as bill_type,
        bill_billing_entity as billing_entity,
        bill_billing_period_start_date as billing_period_start_date,
        bill_billing_period_end_date as billing_period_end_date,
        bill_invoice_id as invoice_id,
        bill_invoicing_entity as invoicing_entity,
        bill_payer_account_id,
        bill_payer_account_name,
        line_item_blended_cost as blended_cost,
        line_item_blended_rate as blended_rate,
        line_item_currency_code as currency_code,
        line_item_normalization_factor as normalization_factor,
        line_item_normalized_usage_amount as normalized_usage_amount,
        line_item_availability_zone as availability_zone,
        line_item_line_item_description as line_item_description,
        line_item_line_item_type as line_item_type,
        line_item_tax_type as tax_type,
        coalesce(line_item_operation, product_operation) as operation,
        line_item_product_code as product_code,
        line_item_unblended_cost as unblended_cost,
        line_item_unblended_rate as unblended_rate,
        line_item_usage_account_id as usage_account_id,
        line_item_usage_account_name as usage_account_name,
        line_item_usage_amount as usage_amount,
        line_item_usage_end_date as usage_end_date,
        line_item_usage_start_date as usage_start_date,
        line_item_usage_type as usage_type,
        pricing_public_on_demand_cost as public_on_demand_cost,
        pricing_public_on_demand_rate as public_on_demand_rate,
        pricing_purchase_option as purchase_option,
        pricing_term,
        coalesce(pricing_unit, product_pricing_unit) as pricing_unit,
        product_fee_code, 
        product_fee_description,

        -- info about product
        product_product_name as product_name,
        product_product_family as product_family,
        product_servicecode as product_service_code,

        -- instances 
        product_instance_type as instance_type,
        product_instance_family as instance_family,

        -- Location data for s3 buckets
        product_location as location,
        product_location_type as location_type,
        product_region_code as region_code,

        -- Location data for data movement (maybe remove from defaults?)
        product_from_location as from_location,
        product_from_location_type as from_location_type,
        product_from_region_code as from_region_code,
        product_to_location as to_location,
        product_to_location_type as to_location_type,
        product_to_region_code as to_region_code,

        -- default: only include reservation + savings plan numeric fields, dimensions can be added via passthroughs
        reservation_amortized_upfront_cost_for_usage,
        reservation_amortized_upfront_fee_for_billing_period,
        reservation_effective_cost,
        reservation_number_of_reservations as number_of_reservations,
        reservation_normalized_units_per_reservation as normalized_units_per_reservation,
        reservation_units_per_reservation as units_per_reservation,
        reservation_total_reserved_normalized_units as total_reserved_normalized_units,
        reservation_total_reserved_units as total_reserved_units,
        reservation_recurring_fee_for_usage,
        reservation_unused_amortized_upfront_fee_for_billing_period,
        reservation_unused_normalized_unit_quantity,
        reservation_unused_quantity,
        reservation_unused_recurring_fee,
        reservation_upfront_value,
        savings_plan_amortized_upfront_commitment_for_billing_period,
        savings_plan_recurring_commitment_for_billing_period,
        savings_plan_savings_plan_effective_cost as savings_plan_effective_cost,
        savings_plan_savings_plan_rate as savings_plan_rate,
        savings_plan_total_commitment_to_date,
        savings_plan_used_commitment 

        {{ fivetran_utils.fill_pass_through_columns('aws_cloud_cost_report_pass_through_columns') }}

    from fields
)

select *
from final
where is_latest_file_version
and billing_period_start_date >= '{{ var("aws_cloud_cost_start_date", "1970-01-01") }}'