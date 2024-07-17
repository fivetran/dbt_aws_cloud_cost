{% docs aws_cloud_cost_report %}

[Standard](https://docs.aws.amazon.com/cur/latest/userguide/dataexports-create-standard.html) Cost & Usage Report (2.0) exported from AWS. Majority of columns are prepended with and reflect information from the following categories (others are either system-generated or JSON fields):

- `bill_`: Data about your bill for the billing period
- `identity_`: Data to identify a line item
- `line_item_`: Data about cost, usage, type of usage, pricing rates, product name, and more
- `pricing_`: Data about the pricing for a line item
- `product_`: Data about the product that is being charged in the line item
- `reservation_`: Data about a reservation that applies to the line item
- `savings_plan_`: Data about savings plans that apply to the line item

{% enddocs %}

{% docs _file %}
Title of the report file from AWS. If you have selected the "create" report delivery, in which each data export produces a new, timestamped version of each report, the `_file` will include this version timestamp. Otherwise, there will be one version of the file that is repeatedly overwritten/appended to by Amazon.
{% enddocs %}

{% docs report %}
The bucket/report combo this belongs to. Parsed out of `_file`.
{% enddocs %}

{% docs _fivetran_synced %}
The time at which fivetran last synced this record.
{% enddocs %}

{% docs source_relation %} The source of the record if the unioning functionality is being used. If not this field will be empty. {% enddocs %}

{% docs _line %} Line number of the report file this record was read from. {% enddocs %}

{% docs _modified %} Timestamp of when the file was read from AWS. {% enddocs %}

{% docs max_modified_for_billing_period %} For each billing period, the most recent `_modified` date. Used to find the latest version of the report file. {% enddocs %}

{% docs bill_bill_type %}
The type of bill that this report covers. There are three bill types:

- Anniversary: Line items for services that you used during the month.
- Purchase: Line items for upfront service fees.
- Refund: Line items for refunds. These will have negative cost amounts.

{% enddocs %}

{% docs bill_billing_entity %}
Helps you identify whether your invoices or transactions are for AWS Marketplace or for purchases of any other AWS services.
{% enddocs %}

{% docs bill_billing_period_end_date %}
The end date of the billing period that is covered by this report, in UTC. The format is `YYYY-MM-DDTHH:mm:ssZ`.
{% enddocs %}

{% docs bill_billing_period_start_date %}
The start date of the billing period that is covered by this report, in UTC. The format is `YYYY-MM-DDTHH:mm:ssZ`.
{% enddocs %}

{% docs bill_invoice_id %}
The ID associated with a specific line item. Until the report is final, the field is blank.
{% enddocs %}

{% docs bill_invoicing_entity %}
The AWS entity that issues the invoice.
{% enddocs %}

{% docs bill_payer_account_id %}
The account ID of the paying account. For an organization in AWS Organizations, this is the account ID of the management account.
{% enddocs %}

{% docs bill_payer_account_name %}
The account name of the paying account. For an organization in AWS Organizations, this is the name of the management account.
{% enddocs %}

{% docs cost_category %}
A map column containing key-value pairs of the cost categories and their values for a given line item. These keys and values are populated based on the categorization rules you create in the cost categories feature.

A cost category key only appears in the map column if it has a value that applies to the specific line item.
{% enddocs %}

{% docs discount %}
(Disabled by `INCLUDE MANUAL DISCOUNT COMPATIBILITY` CUR configuration)

A "struct" column containing key-value pairs of any specific discounts that apply to this line item. The keys correspond to a discount type and the values correspond to either the discount value or other information. The values in this column are either data type "numeric" or "string" depending on the specific key.

This column is not available when "Manual discount compatibility" is enabled. When it's enabled, discounts are populated as separate line items and not in this column.
{% enddocs %}

{% docs identity_line_item_id %}
This field is generated for each line item and is unique in a given partition. This does not guarantee that the field will be unique across an entire delivery (that is, all partitions in an update) of the AWS Cost & Usage Report (CUR). The line item ID isn't consistent between different Cost and Usage Reports and can't be used to identify the same line item across different reports.
{% enddocs %}

{% docs identity_time_interval %}
The time interval that this line item applies to, in the following format: `YYYY-MM-DDTHH:mm:ssZ/YYYY-MM-DDTHH:mm:ssZ`. The time interval is in UTC and can either be daily or hourly, depending on the report granularity.
{% enddocs %}

{% docs line_item_availability_zone %}
The Availability Zone that hosts this line item. For example, `us-east-1a` or `us-east-1b`. Availability Zones are multiple, isolated locations within each Region.
{% enddocs %}

{% docs line_item_blended_cost %}
The `BlendedRate` multiplied by the `UsageAmount`.

`BlendedCost` is blank for line items that have a `LineItemType` of `Discount`. Discounts are calculated using only the unblended cost of a member account, aggregated by member account and SKU. As a result, `BlendedCost` is not available for discounts.
{% enddocs %}

{% docs line_item_blended_rate %}
The BlendedRate is the average cost incurred for each SKU across an organization.

For example, the Amazon S3 blended rates are the total cost of storage divided by the amount of data stored per month. For accounts with RIs, the blended rates are calculated as the average costs of the RIs and the On-Demand Instances.

Blended rates are calculated at the management account level, and used to allocate costs to each member account. For more information, see Blended Rates and Costs in the AWS Billing User [Guide](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/con-bill-blended-rates.html#Blended_CB).
{% enddocs %}

{% docs line_item_currency_code %}
The currency that this line item is shown in. All AWS customers are billed in US dollars by default.
{% enddocs %}

{% docs line_item_legal_entity %}
The Seller of Record of a specific product or service. In most cases, the invoicing entity and legal entity are the same. The values might differ for third-party AWS Marketplace transactions. Possible values include:

- Amazon Web Services, Inc.: The entity that sells AWS services.
- Amazon Web Services India Private Limited: The local Indian entity that acts as a reseller for AWS services in India.

{% enddocs %}

{% docs line_item_line_item_description %}
The description of the line item type. For example, the description of a usage line item summarizes the type of usage incurred during a specific time period.

For size-flexible RIs, the description corresponds to the RI the benefit was applied to. For example, if a line item corresponds to a `t2.micro` and a `t2.small` RI was applied to the usage, the `line_item_line_item_description` displays `t2.small`.

The description for a usage line item with an RI discount contains the pricing plan covered by the line item.
{% enddocs %}

{% docs line_item_line_item_type %}
The type of charge covered by this line item. The possible types are as follows:

- `BundledDiscount`: A usage-based discount that provides free or discounted usage of a service or feature based on the usage of another service or feature.
- `Credit`: Any credits that AWS applied to your bill. See the Description column for details. AWS might update reports after they've been finalized, if AWS applies a credit to your account for the month after finalizing your bill.
- `Discount`: Any discounts that AWS applied to your usage. This specific line item name may vary and require parsing based on the discount. For more information, refer to the `line_item_line_item_description` column.
- `DiscountedUsage`: The rate of any instances for which you had Reserved Instance (RI) benefits. Line items with an RI discount have a `line_item_line_item_type` of `DiscountedUsage`.
- `Fee`: Any upfront annual fee that you paid for subscriptions. For example, the upfront fee that you paid for an All Upfront RI or a Partial Upfront RI.
- `Refund`: The negative charges that AWS refunded money for. Review the Description column for details. AWS might update reports after they've been finalized, if AWS applies a refund to your account for the month after finalizing your bill.
- `RIFee`: The monthly recurring fee for subscriptions. For example, the recurring fee for Partial Upfront RIs, No Upfront RIs, and All Upfronts that you pay every month. Although the RIFee might be $0 for all upfront reservations, this line is still populated for those reservation types to provide other columns such as reservation/AmortizedUpfrontFeeForBillingPeriod and reservation/ReservationARN.
- `Tax`: Any taxes that AWS applied to your bill. For example, VAT or US sales tax. The exact type of tax will be reflected in the `line_item_tax_type` field.
- `Usage`: Any usage that is charged at On-Demand Instance rates.
- `SavingsPlanUpfrontFee`: Any one-time upfront fee from your purchase of an All Upfront or Partial Upfront Savings Plan.
- `SavingsPlanRecurringFee`: Any recurring hourly charges that correspond with your No Upfront or Partial Upfront Savings Plan. The Savings Plan recurring fee is initially added to your bill on the day that you purchase a No Upfront or Partial Upfront Savings Plan. After the initial purchase, AWS adds the recurring fee to the first day of each billing period thereafter.
- `SavingsPlanCoveredUsage`: Any On-Demand cost that is covered by your Savings Plan. Savings Plan covered usage line items are offset by the corresponding Savings Plan negation items.
- `SavingsPlanNegation` – Any offset cost through your Savings Plan benefit that’s associated with the corresponding Savings Plan covered usage item.

{% enddocs %}

{% docs line_item_normalization_factor %}
As long as the instance has shared tenancy, AWS can apply all Regional Linux or Unix Amazon EC2 and Amazon RDS RI discounts to all instance sizes in an instance family and AWS Region. This also applies to RI discounts for member accounts in an organization. All new and existing Amazon EC2 and Amazon RDS size-flexible RIs are sized according to a normalization factor, based on the instance size.
{% enddocs %}

{% docs line_item_normalized_usage_amount %}
The amount of usage that you incurred, in normalized units, for size-flexible RIs. This is equal to `line_item_usage_amount` multiplied by `line_item_normalization_factor`.
{% enddocs %}

{% docs line_item_operation %}
The specific AWS operation covered by this line item. This describes the specific usage of the line item. For example, a value of `RunInstances` indicates the operation of an Amazon EC2 instance.
{% enddocs %}

{% docs line_item_product_code %}
The code of the product measured. For example, Amazon EC2 is the product code for Amazon Elastic Compute Cloud.
{% enddocs %}

{% docs line_item_resource_id %}
(Disabled by default, enabled by: `INCLUDE RESOURCES` CUR configuration) If you chose to include individual resource IDs in your report, this column contains the ID of the resource that you provisioned. For example, an Amazon S3 storage bucket, an Amazon EC2 compute instance, or an Amazon RDS database can each have a resource ID. This field is blank for usage types that aren't associated with an instantiated host, such as data transfers and API requests, and line item types such as discounts, credits, and taxes.
{% enddocs %}

{% docs line_item_tax_type %}
The type of tax that AWS applied to this line item. Null if `line_item_line_item_type != 'Tax'`
{% enddocs %}

{% docs line_item_unblended_cost %}
The UnblendedCost is the UnblendedRate multiplied by the UsageAmount.
{% enddocs %}

{% docs line_item_unblended_rate %}
In consolidated billing for accounts using AWS Organizations, the unblended rate is the rate associated with an individual account's service usage.

For Amazon EC2 and Amazon RDS line items that have an RI discount applied to them, the unblended rate is 0.
{% enddocs %}

{% docs line_item_usage_account_id %}
The account ID of the account that used this line item. For organizations, this can be either the management account or a member account. You can use this field to track costs or usage by account.
{% enddocs %}

{% docs line_item_usage_account_name %}
The name of the account that used this line item. For organizations, this can be either the management account or a member account. You can use this field to track costs or usage by account.
{% enddocs %}

{% docs line_item_usage_amount %}
The amount of usage that you incurred during the specified time period. For size-flexible Reserved Instances, use the `reservation_total_reserved_units` column instead.

Certain subscription charges will have a Usage Amount of 0.
{% enddocs %}

{% docs line_item_usage_end_date %}
The end date and time for the corresponding line item in UTC, exclusive. The format is `YYYY-MM-DDTHH:mm:ssZ`.
{% enddocs %}

{% docs line_item_usage_start_date %}
The start date and time for the line item in UTC, inclusive. The format is `YYYY-MM-DDTHH:mm:ssZ`.
{% enddocs %}

{% docs line_item_usage_type %}
The usage details of the line item. For example, `USW2-BoxUsage:m2.2xlarge` describes an M2 High Memory Double Extra Large instance in the US West (Oregon) Region.
{% enddocs %}

{% docs pricing_currency %}
The currency that the pricing data is shown in.
{% enddocs %}

{% docs pricing_lease_contract_length %}
The length of time that your RI is reserved for.
{% enddocs %}

{% docs pricing_offering_class %}
The offering class of the [Reserved Instance](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/reserved-instances-types.html). Either `Standard`, `Convertible`, or null.
{% enddocs %}

{% docs pricing_public_on_demand_cost %}
The total cost for the line item based on public On-Demand Instance rates. If you have SKUs with multiple On-Demand public costs, the equivalent cost for the highest tier is displayed. For example, services offering free-tiers or tiered pricing.
{% enddocs %}

{% docs pricing_public_on_demand_rate %}
The public On-Demand Instance rate in this billing period for the specific line item of usage. If you have SKUs with multiple On-Demand public rates, the equivalent rate for the highest tier is displayed. For example, services offering free-tiers or tiered pricing.
{% enddocs %}

{% docs pricing_purchase_option %}
How you chose to pay for this line item. Valid values are `All Upfront`, `Partial Upfront`, and `No Upfront`.
{% enddocs %}

{% docs pricing_rate_code %}
A unique code for a product/offer/pricing-tier combination. The product and term combinations can have multiple price dimensions, such as a free tier, low-use tier, and high-use tier.
{% enddocs %}

{% docs pricing_rate_id %}
The ID of the rate for a line item.
{% enddocs %}

{% docs pricing_term %}
Whether your AWS usage is `Reserved`, `On-Demand`, or `Spot`.
{% enddocs %}

{% docs pricing_unit %}
The pricing unit AWS used to calculate your usage cost. For example, the pricing unit for Amazon EC2 instance usage is in hours.
{% enddocs %}

{% docs product %}
A map column containing key-value pairs of multiple product attributes and their values for a given line item.

A product attribute only appears in the map column if it has a value that applies to the specific line item. Any product column that appeared in CUR, but is not part of the CUR 2.0 static schema, appears in this map column.
{% enddocs %}

{% docs product_fee_code %}
The code that refers to the fee.
{% enddocs %}

{% docs product_fee_description %}
The description for the product fee.
{% enddocs %}

{% docs product_from_location %}
Describes the location where the usage originated from.
{% enddocs %}

{% docs product_from_location_type %}
Describes the location type where the usage originated from.
{% enddocs %}

{% docs product_from_region_code %}
Describes the source Region code for the AWS service.
{% enddocs %}

{% docs product_instance_family %}
Describes your Amazon EC2 instance family. Amazon EC2 provides you with a large number of options across 10 different instance types, each with one or more size options, organized into distinct instance families optimized for different types of applications.
{% enddocs %}

{% docs product_instance_type %}
Describes the instance type, size, and family, which define the CPU, networking, and storage capacity of your instance.
{% enddocs %}

{% docs product_location %}
Describes the Region that your Amazon S3 bucket resides in.
{% enddocs %}

{% docs product_location_type %}
Describes the endpoint of your task.
{% enddocs %}

{% docs product_operation %}
Describes the specific AWS operation that this line item covers.
{% enddocs %}

{% docs product_pricing_unit %}
The smallest billing unit for an AWS service. For example, 0.01c per API call.
{% enddocs %}

{% docs product_product_family %}
The category for the type of product.
{% enddocs %}

{% docs product_product_name %}
The longform name of the product.
{% enddocs %}

{% docs product_region_code %}
A Region is a physical location around the world where data centers are clustered. AWS calls each group of logical data centers an Availability Zone (AZ). Each AWS Region consists of multiple, isolated, and physically separate AZs within a geographical area. The Region code attribute has the same name as an AWS Region, and specifies where the AWS service is available.
{% enddocs %}

{% docs product_servicecode %}
This identifies the specific AWS service to the customer as a unique short abbreviation.
{% enddocs %}

{% docs product_sku %}
A unique code for a product. The SKU is created by combining the `line_item_product_code`, `line_item_usage_type`, and `Operation`. For size-flexible RIs, the SKU uses the instance that was used. For example, if you used a `t2.micro` instance and AWS applied a `t2.small` RI discount to the usage, the line item SKU is created with the `t2.micro`.
{% enddocs %}

{% docs product_to_location %}
Describes the location usage destination.
{% enddocs %}

{% docs product_to_location_type %}
Describes the destination location of the service usage.
{% enddocs %}

{% docs product_to_region_code %}
Describes the source Region code for the AWS service.
{% enddocs %}

{% docs product_usagetype %}
Describes the usage details of the line item.
{% enddocs %}

{% docs reservation_amortized_upfront_cost_for_usage %}
The initial upfront payment for all upfront RIs and partial upfront RIs amortized for usage time. The value is equal to: `reservation_amortized_upfront_fee_for_billing_period` * The normalized usage amount for `DiscountedUsage` line items / The normalized usage amount for the `RIFee`. Because there are no upfront payments for no upfront RIs, the value for a no upfront RI is 0. We don't provide this value for Dedicated Host reservations at this time. The change will be made in a future update.
{% enddocs %}

{% docs reservation_amortized_upfront_fee_for_billing_period %}
Describes how much of the upfront fee for this reservation is costing you for the billing period. The initial upfront payment for all upfront RIs and partial upfront RIs, amortized over this month. Because there are no upfront fees for no upfront RIs, the value for no upfront RIs is 0. AWS doesn't provide this value for Dedicated Host reservations at this time. They claim tshe change will be made in a future update.
{% enddocs %}

{% docs reservation_effective_cost %}
The sum of both the upfront and hourly rate of your RI, averaged into an effective hourly rate. `reservation_effective_cost` is calculated by taking the `reservation_amortized_upfront_cost_for_usage` and adding it to the `reservation_recurring_fee_for_usage`.
{% enddocs %}

{% docs reservation_end_time %}
The end date of the associated RI lease term.
{% enddocs %}

{% docs reservation_modification_status %}
Shows whether the RI lease was modified or if it is unaltered. Possible values:

- `Original`: The purchased RI was never modified.
- `System`: The purchased RI was modified using the console or API.
- `Manual`: The purchased RI was modified using AWS Support assistance.
- `ManualWithData`: The purchased RI was modified using AWS Support assistance, and AWS calculated estimates for the RI.

{% enddocs %}

{% docs reservation_normalized_units_per_reservation %}
The number of normalized units for each instance of a reservation subscription.
{% enddocs %}

{% docs reservation_number_of_reservations %}
The number of reservations that are covered by this subscription. For example, one RI subscription might have four associated RI reservations.
{% enddocs %}

{% docs reservation_recurring_fee_for_usage %}
The recurring fee amortized for usage time, for partial upfront RIs and no upfront RIs. The value is equal to: The unblended cost of the `RIFee` * The sum of the normalized usage amount of Usage line items / The normalized usage amount of the `RIFee` for size flexible Reserved Instances. Because all upfront RIs don't have recurring fee payments greater than 0, the value for all upfront RIs is 0.
{% enddocs %}

{% docs reservation_reservation_a_r_n %}
The Amazon Resource Name (ARN) of the RI that this line item benefited from. This is also called the "RI Lease ID". This is a unique identifier of this particular AWS Reserved Instance. The value string also contains the AWS service name and the Region where the RI was purchased.
{% enddocs %}

{% docs reservation_reservation_arn %}
The Amazon Resource Name (ARN) of the RI that this line item benefited from. This is also called the "RI Lease ID". This is a unique identifier of this particular AWS Reserved Instance. The value string also contains the AWS service name and the Region where the RI was purchased.
{% enddocs %}

{% docs reservation_start_time %}
The start date of the term of the associated Reserved Instance.
{% enddocs %}

{% docs reservation_subscription_id %}
A unique identifier that maps a line item with the associated offer. We recommend you use the RI ARN as your identifier of an AWS Reserved Instance, but both can be used.
{% enddocs %}

{% docs reservation_total_reserved_normalized_units %}
The total number of reserved normalized units for all instances for a reservation subscription. AWS computes total normalized units by multiplying the `reservation_normalized_units_per_reservation` with `reservation_number_of_reservations`.
{% enddocs %}

{% docs reservation_total_reserved_units %}
This field populates for both `Fee` and `RIFee` line items with distinct values.

- Fee line items: The total number of units reserved, for the total quantity of leases purchased in your subscription for the entire term. This is calculated by multiplying the `NumberOfReservations` with `UnitsPerReservation`.
- RIFee line items (monthly recurring costs): The total number of available units in your subscription, such as the total number of Amazon EC2 hours in a specific RI subscription.

{% enddocs %}

{% docs reservation_units_per_reservation %}
This field populates for both `Fee` and `RIFee` line items with distinct values.

- Fee line items: The total number of units reserved for the subscription, such as the total number of RI hours purchased for the term of the subscription.
- RIFee line items (monthly recurring costs): The total number of available units in your subscription, such as the total number of Amazon EC2 hours in a specific RI subscription.

{% enddocs %}

{% docs reservation_unused_amortized_upfront_fee_for_billing_period %}
The amortized-upfront-fee-for-billing-period-column amortized portion of the initial upfront fee for all upfront RIs and partial upfront RIs. Because there are no upfront payments for no upfront RIs, the value for no upfront RIs is 0. According to AWS, they doesn't provide this value for Dedicated Host reservations at this time, but the change will be made in a future update.
{% enddocs %}

{% docs reservation_unused_normalized_unit_quantity %}
The number of unused normalized units for a size-flexible Regional RI that you didn't use during this billing period.
{% enddocs %}

{% docs reservation_unused_quantity %}
The number of RI hours that you didn't use during this billing period.
{% enddocs %}

{% docs reservation_unused_recurring_fee %}
The recurring fees associated with your unused reservation hours for partial upfront and no upfront RIs. Because all upfront RIs don't have recurring fees greater than 0, the value for All Upfront RIs is 0.
{% enddocs %}

{% docs reservation_upfront_value %}
The upfront price paid for your AWS Reserved Instance. For no upfront RIs, this value is 0.
{% enddocs %}

{% docs resource_tags %}
A map column containing key-value pairs of resource tags and their values for a given line item. The values in this column are all of data type "string".

Resource tag keys only appear in this column if they've been enabled as cost allocation tags in the Billing console. After being enabled, a particular key only appears in the map column if it has a value that applies to the specific line item.
{% enddocs %}

{% docs savings_plan_amortized_upfront_commitment_for_billing_period %}
The amount of upfront fee a Savings Plan subscription is costing you for the billing period. The initial upfront payment for All Upfront Savings Plan and Partial Upfront Savings Plan amortized over the current month. For No Upfront Savings Plan, the value is 0.
{% enddocs %}

{% docs savings_plan_end_time %}
The expiration date for the Savings Plan agreement.
{% enddocs %}

{% docs savings_plan_offering_type %}
Describes the type of Savings Plan purchased.
{% enddocs %}

{% docs savings_plan_payment_option %}
The payment options available for your Savings Plan.
{% enddocs %}

{% docs savings_plan_purchase_term %}
Describes the duration, or term, of the Savings Plan.
{% enddocs %}

{% docs savings_plan_recurring_commitment_for_billing_period %}
The monthly recurring fee for your Savings Plan subscriptions. For example, the recurring monthly fee for a Partial Upfront Savings Plan or No Upfront Savings Plan.
{% enddocs %}

{% docs savings_plan_region %}
The AWS Region (geographic area) that hosts your AWS services. You can use this field to analyze spend across a particular AWS Region.
{% enddocs %}

{% docs savings_plan_savings_plan_arn %}
The unique Savings Plan identifier.
{% enddocs %}

{% docs savings_plan_savings_plan_effective_cost %}
The proportion of the Savings Plan monthly commitment amount (upfront and recurring) that is allocated to each usage line.
{% enddocs %}

{% docs savings_plan_savings_plan_rate %}
The Savings Plan rate for the usage.
{% enddocs %}

{% docs savings_plan_start_time %}
The start date of the Savings Plan agreement.
{% enddocs %}

{% docs savings_plan_total_commitment_to_date %}
The total amortized upfront commitment and recurring commitment to date, for that hour.
{% enddocs %}

{% docs savings_plan_used_commitment %}
The total dollar amount of the Savings Plan commitment used. (SavingsPlanRate multiplied by usage)
{% enddocs %}