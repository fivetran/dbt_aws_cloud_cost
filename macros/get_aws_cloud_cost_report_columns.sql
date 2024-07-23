{% macro get_aws_cloud_cost_report_columns() %}

{% set columns = [
    {"name": "_file", "datatype": dbt.type_string()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "_line", "datatype": dbt.type_int()},
    {"name": "_modified", "datatype": dbt.type_timestamp()},
    {"name": "bill_bill_type", "datatype": dbt.type_string()},
    {"name": "bill_billing_entity", "datatype": dbt.type_string()},
    {"name": "bill_billing_period_end_date", "datatype": dbt.type_timestamp()},
    {"name": "bill_billing_period_start_date", "datatype": dbt.type_timestamp()},
    {"name": "bill_invoice_id", "datatype": dbt.type_int()},
    {"name": "bill_invoicing_entity", "datatype": dbt.type_string()},
    {"name": "bill_payer_account_id", "datatype": dbt.type_int()},
    {"name": "bill_payer_account_name", "datatype": dbt.type_string()},
    {"name": "identity_line_item_id", "datatype": dbt.type_string()},
    {"name": "identity_time_interval", "datatype": dbt.type_string()},
    {"name": "line_item_availability_zone", "datatype": dbt.type_string()},
    {"name": "line_item_blended_cost", "datatype": dbt.type_float()},
    {"name": "line_item_blended_rate", "datatype": dbt.type_float()},
    {"name": "line_item_currency_code", "datatype": dbt.type_string()},
    {"name": "line_item_line_item_description", "datatype": dbt.type_string()},
    {"name": "line_item_line_item_type", "datatype": dbt.type_string()},
    {"name": "line_item_normalization_factor", "datatype": dbt.type_float()},
    {"name": "line_item_normalized_usage_amount", "datatype": dbt.type_float()},
    {"name": "line_item_operation", "datatype": dbt.type_string()},
    {"name": "line_item_product_code", "datatype": dbt.type_string()},
    {"name": "line_item_resource_id", "datatype": dbt.type_string()},
    {"name": "line_item_tax_type", "datatype": dbt.type_string()},
    {"name": "line_item_unblended_cost", "datatype": dbt.type_float()},
    {"name": "line_item_unblended_rate", "datatype": dbt.type_float()},
    {"name": "line_item_usage_account_id", "datatype": dbt.type_int()},
    {"name": "line_item_usage_account_name", "datatype": dbt.type_string()},
    {"name": "line_item_usage_amount", "datatype": dbt.type_float()},
    {"name": "line_item_usage_end_date", "datatype": dbt.type_timestamp()},
    {"name": "line_item_usage_start_date", "datatype": dbt.type_timestamp()},
    {"name": "line_item_usage_type", "datatype": dbt.type_string()},
    {"name": "pricing_currency", "datatype": dbt.type_string()},
    {"name": "pricing_public_on_demand_cost", "datatype": dbt.type_float()},
    {"name": "pricing_public_on_demand_rate", "datatype": dbt.type_float()},
    {"name": "pricing_purchase_option", "datatype": dbt.type_string()},
    {"name": "pricing_term", "datatype": dbt.type_string()},
    {"name": "pricing_unit", "datatype": dbt.type_string()},
    {"name": "product_pricing_unit", "datatype": dbt.type_string()},
    {"name": "product_fee_code", "datatype": dbt.type_string()},
    {"name": "product_fee_description", "datatype": dbt.type_string()},
    {"name": "product_from_location", "datatype": dbt.type_string()},
    {"name": "product_from_location_type", "datatype": dbt.type_string()},
    {"name": "product_from_region_code", "datatype": dbt.type_string()},
    {"name": "product_instance_family", "datatype": dbt.type_string()},
    {"name": "product_instance_type", "datatype": dbt.type_string()},
    {"name": "product_location", "datatype": dbt.type_string()},
    {"name": "product_location_type", "datatype": dbt.type_string()},
    {"name": "product_operation", "datatype": dbt.type_string()},
    {"name": "product_product_name", "datatype": dbt.type_string()},
    {"name": "product_product_family", "datatype": dbt.type_string()},
    {"name": "product_region_code", "datatype": dbt.type_string()},
    {"name": "product_servicecode", "datatype": dbt.type_string()},
    {"name": "product_to_location", "datatype": dbt.type_string()},
    {"name": "product_to_location_type", "datatype": dbt.type_string()},
    {"name": "product_to_region_code", "datatype": dbt.type_string()},
    {"name": "product_usagetype", "datatype": dbt.type_string()},
    {"name": "reservation_amortized_upfront_cost_for_usage", "datatype": dbt.type_float()},
    {"name": "reservation_amortized_upfront_fee_for_billing_period", "datatype": dbt.type_float()},
    {"name": "reservation_effective_cost", "datatype": dbt.type_float()},
    {"name": "reservation_normalized_units_per_reservation", "datatype": dbt.type_float()},
    {"name": "reservation_number_of_reservations", "datatype": dbt.type_int()},
    {"name": "reservation_recurring_fee_for_usage", "datatype": dbt.type_float()},
    {"name": "reservation_total_reserved_normalized_units", "datatype": dbt.type_float()},
    {"name": "reservation_total_reserved_units", "datatype": dbt.type_float()},
    {"name": "reservation_units_per_reservation", "datatype": dbt.type_float()},
    {"name": "reservation_unused_amortized_upfront_fee_for_billing_period", "datatype": dbt.type_float()},
    {"name": "reservation_unused_normalized_unit_quantity", "datatype": dbt.type_float()},
    {"name": "reservation_unused_quantity", "datatype": dbt.type_float()},
    {"name": "reservation_unused_recurring_fee", "datatype": dbt.type_float()},
    {"name": "reservation_upfront_value", "datatype": dbt.type_float()},
    {"name": "savings_plan_amortized_upfront_commitment_for_billing_period", "datatype": dbt.type_float()},
    {"name": "savings_plan_recurring_commitment_for_billing_period", "datatype": dbt.type_float()},
    {"name": "savings_plan_savings_plan_effective_cost", "datatype": dbt.type_float()},
    {"name": "savings_plan_savings_plan_rate", "datatype": dbt.type_float()},
    {"name": "savings_plan_total_commitment_to_date", "datatype": dbt.type_float()},
    {"name": "savings_plan_used_commitment", "datatype": dbt.type_float()}
] %}

{{ fivetran_utils.add_pass_through_columns(columns, var('aws_cloud_cost_report_pass_through_columns')) }}

{{ return(columns) }}

{% endmacro %}
