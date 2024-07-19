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
        line_item_usage_account_id,
        line_item_usage_account_name,
        source_relation,
        max(line_item_usage_start_date) as latest_start_date

    from source_report
    where line_item_usage_account_name is not null
    group by 1,2,3
),

usage_account_names as (

    select
        sub.line_item_usage_account_id,
        sub.line_item_usage_account_name,
        sub.source_relation
    from (
        {# In case the account name as been updated, let's ensure we're only grabbing the most recent one #}
        select 
            line_item_usage_account_id,
            line_item_usage_account_name,
            source_relation,
            row_number() over (partition by line_item_usage_account_id, source_relation order by latest_start_date desc) = 1 as is_latest_name
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
        cast({{ dbt.date_trunc('day', 'line_item_usage_start_date') }} as date) as usage_start_date,
        cast({{ dbt.date_trunc('day', 'line_item_usage_end_date') }} as date) as usage_end_date, -- keep just in case
        billing_period_start_date,
        billing_period_end_date,

        {# Account Details #}
        source_report.line_item_usage_account_id,
        coalesce(source_report.line_item_usage_account_name, usage_account_names.line_item_usage_account_name) as line_item_usage_account_name,
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
        pricing_purchase_option,
        pricing_term,
        product_fee_code,
        product_fee_description,

        {# Units #}
        pricing_unit,
        line_item_usage_type,
        line_item_currency_code,
        
        {# Line Item Service Details #}
        line_item_description,
        line_item_resource_id, -- null unless you've enabled `INCLUDE RESOURCES` in your AWS CUR configuration
        line_item_product_code,
        product_service_code,
        product_name,
        product_family,
        operation,

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
        max(savings_plan_effective_cost) as savings_plan_effective_cost,
        max(savings_plan_rate) as savings_plan_rate,
        max(savings_plan_total_commitment_to_date) as savings_plan_total_commitment_to_date,
        max(savings_plan_used_commitment) as savings_plan_used_commitment 

    from source_report
    left join billing_account_names
        on source_report.bill_payer_account_id = billing_account_names.bill_payer_account_id
        and source_report.source_relation = billing_account_names.source_relation
    left join usage_account_names
        on source_report.line_item_usage_account_id = usage_account_names.line_item_usage_account_id
        and source_report.source_relation = usage_account_names.source_relation

    {{ dbt_utils.group_by(n=42 + var('aws_cloud_cost_report_pass_through_columns',[])|length) }}
),

final as (
{%- set composite_key = [
        'source_relation',
        'report', 
        'usage_start_date',
        'usage_end_date',
        'billing_period_start_date',
        'billing_period_end_date',
        'line_item_usage_account_id',
        'line_item_usage_account_name',
        'bill_payer_account_id',
        'bill_payer_account_name',
        'bill_invoice_id',
        'bill_invoicing_entity',
        'billing_entity',
        'bill_type', 
        'line_item_type',
        'line_item_tax_type',
        'pricing_purchase_option',
        'pricing_term',
        'product_fee_code',
        'product_fee_description',
        'pricing_unit',
        'line_item_usage_type',
        'line_item_currency_code',
        'line_item_description',
        'line_item_resource_id',
        'line_item_product_code',
        'product_service_code',
        'product_name',
        'product_family',
        'operation',
        'product_location',
        'product_location_type',
        'product_region_code',
        'line_item_availability_zone',
        'product_from_location',
        'product_from_location_type',
        'product_from_region_code',
        'product_to_location',
        'product_to_location_type',
        'product_to_region_code',
        'product_instance_family',
        'product_instance_type'
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