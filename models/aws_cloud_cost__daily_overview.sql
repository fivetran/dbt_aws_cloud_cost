with source_report as (

    select *
    from {{ ref('stg_aws_cloud_cost__report') }}
),

final as (

    select 
        source_relation,
        report, 

        {# Period Details #}
        {{ dbt.date_trunc('day', 'line_item_usage_start_date') }} as date_day,
        bill_billing_period_start_date,
        bill_billing_period_end_date,

        {# Account Details #}
        line_item_usage_account_id,
        line_item_usage_account_name,
        bill_payer_account_id,
        bill_payer_account_name,

        {# Billing Details #}
        bill_invoice_id,
        bill_invoicing_entity,
        bill_billing_entity,
        bill_bill_type, 
        line_item_type,
        line_item_tax_type,

        {# Units #}
        line_item_currency_code,
        pricing_currency,
        pricing_unit,
        line_item_usage_type, -- usage_unit basically

        {# Pricing Details #}
        pricing_purchase_option,
        pricing_term,
        product_fee_code,
        product_fee_description,

        {# Line Item Service Details #}
        line_item_description,
        line_item_resource_id, -- if available
        line_item_product_code,
        product_name,
        product_family,
        line_item_operation,

        {# Product Details - s3 #}
        product_location,
        product_location_type,
        product_region_code,
        line_item_availability_zone,

        {# Product Details - Data transfers/movement #}
        product_from_location,
        product_from_location_type,
        product_from_region_code,
        product_to_location,
        product_to_location_type,
        product_to_region_code,

        {# Product Details - Compute #}
        product_instance_family,
        product_instance_type

        {{ fivetran_utils.persist_pass_through_columns(pass_through_variable='aws_cloud_cost_report_pass_through_columns') }},

        {# Usage Metrics #}
        sum(coalesce(line_item_usage_amount, 0)) as usage_amount,
        sum(coalesce(line_item_normalized_usage_amount, 0)) as normalized_usage_amount,
        max(line_item_normalization_factor) as line_item_normalization_factor,

        {# Cost Metrics - General #}
        sum(coalesce(line_item_blended_cost, 0)) as blended_cost,
        sum(coalesce(line_item_unblended_cost, 0)) as unblended_cost,
        sum(coalesce(pricing_public_on_demand_cost, 0)) as pricing_public_on_demand_cost,
        avg(line_item_blended_rate) as avg_blended_rate,
        max(line_item_unblended_rate) as avg_unblended_rate,
        avg(pricing_public_on_demand_rate) as avg_pricing_public_on_demand_rate,

        {# Cost & Usage Metrics - Reservations #}
        max(reservation_amortized_upfront_cost_for_usage) as reservation_amortized_upfront_cost_for_usage,
        max(reservation_amortized_upfront_fee_for_billing_period) as reservation_amortized_upfront_fee_for_billing_period,
        max(reservation_effective_cost) as reservation_effective_cost,
        max(reservation_number_of_reservations) as reservation_number_of_reservations,
        max(reservation_normalized_units_per_reservation) as reservation_normalized_units_per_reservation,
        max(reservation_units_per_reservation) as reservation_units_per_reservation,
        max(reservation_total_reserved_normalized_units) as reservation_total_reserved_normalized_units,
        max(reservation_total_reserved_units) as reservation_total_reserved_units,
        max(reservation_recurring_fee_for_usage) as reservation_recurring_fee_for_usage,
        max(reservation_unused_amortized_upfront_fee_for_billing_period) as reservation_unused_amortized_upfront_fee_for_billing_period,
        max(reservation_unused_normalized_unit_quantity) as reservation_unused_normalized_unit_quantity,
        max(reservation_unused_quantity) as reservation_unused_quantity,
        max(reservation_unused_recurring_fee) as reservation_unused_recurring_fee,
        max(reservation_upfront_value) as reservation_upfront_value,

        {# Cost & Usage Metrics - Savings Plans #}
        max(savings_plan_amortized_upfront_commitment_for_billing_period) as savings_plan_amortized_upfront_commitment_for_billing_period,
        max(savings_plan_recurring_commitment_for_billing_period) as savings_plan_recurring_commitment_for_billing_period,
        max(savings_plan_savings_plan_effective_cost) as savings_plan_savings_plan_effective_cost,
        max(savings_plan_savings_plan_rate) as savings_plan_savings_plan_rate,
        max(savings_plan_total_commitment_to_date) as savings_plan_total_commitment_to_date,
        max(savings_plan_used_commitment) as savings_plan_used_commitment 

    from source_report

    {{ dbt_utils.group_by(n=41+var('aws_cloud_cost_report_pass_through_columns',[])|length) }}
)

select *
from final