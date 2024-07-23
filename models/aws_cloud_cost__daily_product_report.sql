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
        pricing_unit,
        product_code,
        product_name,
        {# Possible future feature: add variable to persist passthrough columns in this model #}
        count(distinct region_code) as count_regions,
        count(distinct usage_type) as count_instances,
        sum(coalesce(usage_amount, 0)) as usage_amount,
        sum(coalesce(normalized_usage_amount, 0)) as normalized_usage_amount,
        sum(coalesce(blended_cost, 0)) as total_blended_cost,
        sum(coalesce(unblended_cost, 0)) as total_unblended_cost,
        sum(coalesce(public_on_demand_cost, 0)) as total_public_on_demand_cost

        {% for bill_type in ('anniversary', 'purchase', 'refund') %}
        ,    sum(case when lower(bill_type) = '{{ bill_type }}' then blended_cost else 0 end) as {{ bill_type }}_blended_cost
        ,    sum(case when lower(bill_type) = '{{ bill_type }}' then unblended_cost else 0 end) as {{ bill_type }}_unblended_cost
        ,    sum(case when lower(bill_type) = '{{ bill_type }}' then public_on_demand_cost else 0 end) as {{ bill_type }}_public_on_demand_cost
        {% endfor %}

    from base 
    {{ dbt_utils.group_by(n=13) }}
),

final as (

    select
        *,
        {# Grain is connector - report - account - usage day - billing month - currency + usage units - AWS product #}
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
            'pricing_unit',
            'product_code',
            'product_name'
        ]) }} as unique_key
    from fields
)

select *
from final