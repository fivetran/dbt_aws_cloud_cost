{{
    config(
        materialized='table',
        partition_by = {'field': 'usage_start_date', 'data_type': 'date'}
            if target.type not in ['spark', 'databricks'] else ['usage_start_date'],       
        cluster_by = ['billing_period_start_date'],
        unique_key='unique_key'
    )
}}

with source_report as (

    select *
    from {{ ref('stg_aws_cloud_cost__report') }}
),

{# Sometimes records are sent with just IDs and null names. The following 2 CTEs will map account names
to their IDs so we can fill these in when needed. #}
usage_account_mapping as (

    select 
        usage_account_id,
        usage_account_name,
        source_relation,
        max(usage_start_date) as latest_start_date

    from source_report
    where usage_account_name is not null
    group by 1,2,3
),

usage_account_names as (

    select
        sub.usage_account_id,
        sub.usage_account_name,
        sub.source_relation
    from (
        {# In case the account name as been updated, let's ensure we're only grabbing the most recent one #}
        select 
            usage_account_id,
            usage_account_name,
            source_relation,
            row_number() over (partition by usage_account_id, source_relation order by latest_start_date desc) = 1 as is_latest_name
        from usage_account_mapping
    ) as sub where is_latest_name
),

{# Sometimes records are sent with just IDs and null names. The following 2 CTEs will map account names
to their IDs so we can fill these in when needed. #}
billing_account_mapping as (

    select 
        bill_payer_account_id,
        bill_payer_account_name,
        source_relation,
        max(billing_period_start_date) as latest_start_date

    from source_report
    where bill_payer_account_name is not null
    group by 1,2,3
),

billing_account_names as (

    select
        sub.bill_payer_account_id,
        sub.bill_payer_account_name,
        sub.source_relation
    from (
        {# In case the account name as been updated, let's ensure we're only grabbing the most recent one #}
        select 
            bill_payer_account_id,
            bill_payer_account_name,
            source_relation,
            row_number() over (partition by bill_payer_account_id, source_relation order by latest_start_date desc) = 1 as is_latest_name
        from billing_account_mapping
    ) as sub where is_latest_name
),

fields as (

    select 
        source_report.source_relation,
        report, 

        {# Period Details #}
        cast({{ dbt.date_trunc('day', 'usage_start_date') }} as date) as usage_start_date,
        cast({{ dbt.date_trunc('day', 'usage_end_date') }} as date) as usage_end_date, -- keep just in case
        billing_period_start_date,
        billing_period_end_date,

        {# Account Details #}
        source_report.usage_account_id,
        coalesce(source_report.usage_account_name, usage_account_names.usage_account_name) as usage_account_name,
        source_report.bill_payer_account_id,
        coalesce(source_report.bill_payer_account_name, billing_account_names.bill_payer_account_name) as bill_payer_account_name,

        {# Billing Details #}
        bill_invoice_id,
        bill_invoicing_entity,
        billing_entity,
        bill_type, 
        line_item_type,
        line_item_tax_type,

        {# Pricing Details #}
        purchase_option,
        pricing_term,
        product_fee_code,
        product_fee_description,

        {# Units #}
        pricing_unit,
        usage_type,
        currency_code,
        
        {# Line Item Service Details #}
        line_item_description,
        product_code,
        product_name,
        product_service_code, -- service is within product
        product_family,
        operation,

        {# Product Details - Compute #}
        instance_type,
        instance_family,

        {# Product Details - s3 #}
        location,
        location_type,
        region_code,
        availability_zone,

        {# Product Details - Data transfers/movement #}
        from_location,
        from_location_type,
        from_region_code,
        to_location,
        to_location_type,
        to_region_code

        {{ fivetran_utils.persist_pass_through_columns(pass_through_variable='aws_cloud_cost_report_pass_through_columns') }},

        {# Usage Metrics #}
        cast(sum(coalesce(usage_amount, 0)) as {{ dbt.type_numeric() }}) as usage_amount,
        cast(sum(coalesce(normalized_usage_amount, 0)) as {{ dbt.type_numeric() }}) as normalized_usage_amount,
        cast(max(normalization_factor) as {{ dbt.type_numeric() }}) as normalization_factor,

        {# Cost Metrics - General #}
        cast(sum(coalesce(blended_cost, 0)) as {{ dbt.type_numeric() }}) as blended_cost,
        cast(sum(coalesce(unblended_cost, 0)) as {{ dbt.type_numeric() }}) as unblended_cost,
        cast(sum(coalesce(public_on_demand_cost, 0)) as {{ dbt.type_numeric() }}) as public_on_demand_cost,
        cast(avg(blended_rate) as {{ dbt.type_numeric() }}) as avg_blended_rate,
        cast(avg(unblended_rate) as {{ dbt.type_numeric() }}) as avg_unblended_rate,
        cast(avg(public_on_demand_rate) as {{ dbt.type_numeric() }}) as avg_public_on_demand_rate,
        cast(count(*) as {{ dbt.type_numeric() }}) as count_line_items,

        {# Cost & Usage Metrics - Reservations 
            Using MAX's + MIN's under the assumption that there is a 1:Many relationship between Reservations and Line Items 
        #}
        cast(max(reservation_amortized_upfront_cost_for_usage) as {{ dbt.type_numeric() }}) as reservation_amortized_upfront_cost_for_usage,
        cast(max(reservation_amortized_upfront_fee_for_billing_period) as {{ dbt.type_numeric() }}) as reservation_amortized_upfront_fee_for_billing_period,
        cast(max(reservation_effective_cost) as {{ dbt.type_numeric() }}) as reservation_effective_cost,
        cast(max(number_of_reservations) as {{ dbt.type_numeric() }}) as number_of_reservations,
        cast(max(normalized_units_per_reservation) as {{ dbt.type_numeric() }}) as normalized_units_per_reservation,
        cast(max(units_per_reservation) as {{ dbt.type_numeric() }}) as units_per_reservation,
        cast(max(total_reserved_normalized_units) as {{ dbt.type_numeric() }}) as total_reserved_normalized_units,
        cast(max(total_reserved_units) as {{ dbt.type_numeric() }}) as total_reserved_units,
        
        cast(max(reservation_recurring_fee_for_usage) as {{ dbt.type_numeric() }}) as reservation_recurring_fee_for_usage,
        cast(min(reservation_unused_amortized_upfront_fee_for_billing_period) as {{ dbt.type_numeric() }}) as reservation_unused_amortized_upfront_fee_for_billing_period,
        cast(min(reservation_unused_normalized_unit_quantity) as {{ dbt.type_numeric() }}) as reservation_unused_normalized_unit_quantity,
        cast(min(reservation_unused_quantity) as {{ dbt.type_numeric() }}) as reservation_unused_quantity,
        cast(min(reservation_unused_recurring_fee) as {{ dbt.type_numeric() }}) as reservation_unused_recurring_fee,
        cast(max(reservation_upfront_value) as {{ dbt.type_numeric() }}) as reservation_upfront_value,

        {# Cost & Usage Metrics - Savings Plans #}
        cast(max(savings_plan_amortized_upfront_commitment_for_billing_period) as {{ dbt.type_numeric() }}) as savings_plan_amortized_upfront_commitment_for_billing_period,
        cast(max(savings_plan_recurring_commitment_for_billing_period) as {{ dbt.type_numeric() }}) as savings_plan_recurring_commitment_for_billing_period,
        cast(max(savings_plan_effective_cost) as {{ dbt.type_numeric() }}) as savings_plan_effective_cost,
        cast(max(savings_plan_rate) as {{ dbt.type_numeric() }}) as savings_plan_rate,
        cast(max(savings_plan_total_commitment_to_date) as {{ dbt.type_numeric() }}) as savings_plan_total_commitment_to_date,
        cast(max(savings_plan_used_commitment) as {{ dbt.type_numeric() }}) as savings_plan_used_commitment 

    from source_report
    left join billing_account_names
        on source_report.bill_payer_account_id = billing_account_names.bill_payer_account_id
        and source_report.source_relation = billing_account_names.source_relation
    left join usage_account_names
        on source_report.usage_account_id = usage_account_names.usage_account_id
        and source_report.source_relation = usage_account_names.source_relation

    {{ dbt_utils.group_by(n=41 + var('aws_cloud_cost_report_pass_through_columns',[])|length) }}
),

final as (
{%- set composite_key = [
        'source_relation',
        'report', 
        'usage_start_date',
        'usage_end_date',
        'billing_period_start_date',
        'billing_period_end_date',
        'usage_account_id',
        'usage_account_name',
        'bill_payer_account_id',
        'bill_payer_account_name',
        'bill_invoice_id',
        'bill_invoicing_entity',
        'billing_entity',
        'bill_type', 
        'line_item_type',
        'line_item_tax_type',
        'purchase_option',
        'pricing_term',
        'product_fee_code',
        'product_fee_description',
        'pricing_unit',
        'usage_type',
        'currency_code',
        'line_item_description',
        'product_code',
        'product_service_code',
        'product_name',
        'product_family',
        'operation',
        'instance_family',
        'instance_type',
        'location',
        'location_type',
        'region_code',
        'availability_zone',
        'from_location',
        'from_location_type',
        'from_region_code',
        'to_location',
        'to_location_type',
        'to_region_code'
    ] 
-%}

{% for field in var('aws_cloud_cost_report_pass_through_columns', [])  -%}
    {% set field_name = field.alias|default(field.name)|lower %}
    {% do composite_key.append(field_name) %}
{% endfor -%}

    select 
        *, 
        {{ dbt_utils.generate_surrogate_key(composite_key) }} as unique_key
    from fields
)

select *
from final