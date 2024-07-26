with base as (

    select *
    from {{ ref('aws_cloud_cost__daily_overview') }}
),

fields as (

    select 
        source_relation,
        report,
        usage_start_date as usage_date,
        billing_period_start_date,
        billing_period_end_date,
        usage_account_id,
        usage_account_name,
        bill_payer_account_id,
        bill_payer_account_name,
        currency_code,
        usage_type,

        {# Possible future feature: add variable to persist passthrough columns from daily_overview in this model #}

        count(distinct product_service_code) as count_products,
        count(distinct region_code) as count_regions,
        sum(coalesce(usage_amount, 0)) as usage_amount,
        sum(coalesce(normalized_usage_amount, 0)) as normalized_usage_amount,
        sum(coalesce(total_reserved_units, 0)) as total_reserved_units, -- use this for size-flexible Reserved Instances
        sum(coalesce(blended_cost, 0)) as total_blended_cost,
        sum(coalesce(unblended_cost, 0)) as total_unblended_cost,
        sum(coalesce(public_on_demand_cost, 0)) as total_public_on_demand_cost

        {# Possible future features: split and pivot costs by:
            - pricing_term of usage: Reserved vs On Demand vs Spot
            - bill_type: Anniversary vs Purchase vs Refund
            - purchase_option: pay All Upfront, Partial Upfront, None Upfront
        #}
        
    from base 
    {{ dbt_utils.group_by(n=11) }}
),

final as (

    select
        *,
        {# Grain is connector - report - account - usage day - billing month - currency - EC2 type #}
        {{ dbt_utils.generate_surrogate_key([
            'source_relation',
            'report',
            'usage_date',
            'billing_period_start_date',
            'billing_period_end_date',
            'usage_account_id',
            'usage_account_name',
            'bill_payer_account_id',
            'bill_payer_account_name',
            'currency_code',
            'usage_type'
        ]) }} as unique_key
    from fields
)

select *
from final