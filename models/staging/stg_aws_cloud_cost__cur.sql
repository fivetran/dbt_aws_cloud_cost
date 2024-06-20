
with base as (

    select * 
    from {{ ref('stg_aws_cloud_cost__cur_base') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_aws_cloud_cost__cur_base')),
                staging_columns=get_cur_columns()
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
        
        bill_bill_type, -- include 
        bill_billing_entity, -- include ?
        bill_billing_period_start_date, -- include
        bill_billing_period_end_date, -- include
        bill_invoice_id, -- do people wanna include with other financials?
        bill_invoicing_entity, -- include
        bill_payer_account_id, -- include? internally we look at line_item_usage_account
        bill_payer_account_name, -- include? 

        {# cost_category, -- json
        discount, -- json  #}

        identity_line_item_id, -- supposed to be PK within a report
        identity_time_interval, -- doesn't actually line up
        {{ dbt.split_part(string_text='identity_time_interval', delimiter_text="'/'", part_number=1) }} as identity_time_interval_start,
        {{ dbt.split_part(string_text='identity_time_interval', delimiter_text="'/'", part_number=2) }} as identity_time_interval_end,
        
        line_item_availability_zone, -- include
        line_item_blended_cost, -- include
        line_item_blended_rate, -- include
        line_item_currency_code, -- include

        {# line_item_legal_entity, #} -- either AWS or AWS India

        line_item_line_item_description, -- include
        line_item_line_item_type, -- include

        line_item_normalization_factor, -- include
        line_item_normalized_usage_amount, -- include

        line_item_operation, -- include
        line_item_product_code, -- include
        line_item_resource_id, -- null unless you've enabled `INCLUDE RESOURCES` in your AWS CUR configuration
        line_item_tax_type, -- include
        line_item_unblended_cost, -- include
        line_item_unblended_rate, -- include
        line_item_usage_account_id, -- include
        line_item_usage_account_name, -- include
        line_item_usage_amount, -- include
        line_item_usage_end_date, -- include
        line_item_usage_start_date, -- include
        line_item_usage_type, -- include

        pricing_currency, -- include
        {# pricing_lease_contract_length, #}
        {# pricing_offering_class, #}
        pricing_public_on_demand_cost, -- sum 
        pricing_public_on_demand_rate, -- average
        pricing_purchase_option, -- include
        {# pricing_rate_code,
        pricing_rate_id, #}
        pricing_term, -- include
        pricing_unit, -- include

        {# product, -- json #}
        product_fee_code, -- include -> similar to line_item_description
        product_fee_description, -- include

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
        
        -- info about product
        product_operation,
        {# product_pricing_unit, covered by line item#}
        product_product_family,
        product_servicecode as product_service_code,
        {# product_sku, un needed#}

        {# product_usagetype,  covered by line item #}

        -- maybe only include reservation + savings plan numeric fields, dims cna be added as passthroughs

        reservation_amortized_upfront_cost_for_usage, -- sum
        reservation_amortized_upfront_fee_for_billing_period, -- sum 
        reservation_effective_cost, -- sum
        {# reservation_start_time,
        reservation_end_time, #}

        {# reservation_modification_status, #}
        reservation_number_of_reservations, -- sum 
        reservation_normalized_units_per_reservation, -- sum/avg
        reservation_units_per_reservation, -- sum/avg
        reservation_total_reserved_normalized_units,
        reservation_total_reserved_units, -- sum

        reservation_recurring_fee_for_usage, -- sum

        {# coalesce(reservation_reservation_arn, reservation_reservation_a_r_n) as reservation_reservation_arn, #}
        
        {# reservation_subscription_id, #}
        
        reservation_unused_amortized_upfront_fee_for_billing_period,
        reservation_unused_normalized_unit_quantity,
        reservation_unused_quantity,
        reservation_unused_recurring_fee,
        reservation_upfront_value,

        {# resource_tags, -- json#}

        savings_plan_amortized_upfront_commitment_for_billing_period,
        {# savings_plan_end_time, #}
        {# savings_plan_offering_type, #}
        {# savings_plan_payment_option, #}
        {# savings_plan_purchase_term, #}
        savings_plan_recurring_commitment_for_billing_period,
        {# savings_plan_region, #}
        {# savings_plan_savings_plan_arn, #}
        savings_plan_savings_plan_effective_cost,
        savings_plan_savings_plan_rate,
        {# savings_plan_start_time, #}
        savings_plan_total_commitment_to_date,
        savings_plan_used_commitment 

    from fields
)

select *
from final
where is_latest_file_version
