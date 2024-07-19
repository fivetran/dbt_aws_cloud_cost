with base as (

    select *
    from {{ ref('aws_cloud_cost__overview') }}
),

final as (

    select 
        source_relation,
        report,
        usage_start_date,
        usage_end_date,
        billing_period_start_date,
        billing_period_end_date,
        usage_account_id,
        usage_account_name,
        bill_payer_account_id,
        bill_payer_account_name,
        bill_type, 
        line_item_type,
        line_item_tax_type,
        currency_code,
        pricing_unit,
        product_code,
        product_name,

        sum(coalesce(usage_amount, 0)) as usage_amount,
        sum(coalesce(normalized_usage_amount, 0)) as normalized_usage_amount,
        max(normalization_factor) as normalization_factor,
        sum(coalesce(blended_cost, 0)) as blended_cost,
        sum(coalesce(unblended_cost, 0)) as unblended_cost,
        sum(coalesce(public_on_demand_cost, 0)) as public_on_demand_cost,

        {# Cost & Usage Metrics - Reservations #}
        max(reservation_amortized_upfront_cost_for_usage) as reservation_amortized_upfront_cost_for_usage,
        max(reservation_amortized_upfront_fee_for_billing_period) as reservation_amortized_upfront_fee_for_billing_period,
        max(reservation_effective_cost) as reservation_effective_cost,
        max(number_of_reservations) as number_of_reservations,
        max(normalized_units_per_reservation) as normalized_units_per_reservation,
        max(units_per_reservation) as units_per_reservation,
        max(total_reserved_normalized_units) as total_reserved_normalized_units,
        max(total_reserved_units) as total_reserved_units,
        max(reservation_recurring_fee_for_usage) as reservation_recurring_fee_for_usage,
        max(reservation_unused_amortized_upfront_fee_for_billing_period) as reservation_unused_amortized_upfront_fee_for_billing_period,
        max(reservation_unused_normalized_unit_quantity) as reservation_unused_normalized_unit_quantity,
        max(reservation_unused_quantity) as reservation_unused_quantity,
        max(reservation_unused_recurring_fee) as reservation_unused_recurring_fee,
        max(reservation_upfront_value) as reservation_upfront_value,

        {# Cost & Usage Metrics - Savings Plans #}
        max(savings_plan_amortized_upfront_commitment_for_billing_period) as savings_plan_amortized_upfront_commitment_for_billing_period,
        max(savings_plan_recurring_commitment_for_billing_period) as savings_plan_recurring_commitment_for_billing_period,
        max(savings_plan_effective_cost) as savings_plan_effective_cost,
        max(savings_plan_rate) as savings_plan_rate,
        max(savings_plan_total_commitment_to_date) as savings_plan_total_commitment_to_date,
        max(savings_plan_used_commitment) as savings_plan_used_commitment 

    from base 
    {{ dbt_utils.group_by(n=17) }}
)

select *
from final