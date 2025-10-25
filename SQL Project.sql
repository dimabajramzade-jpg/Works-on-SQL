select *
from google_ads_basic_daily;
select *
from facebook_ads_basic_daily;

-------Завдання 1 
-----Відобрази агрегуючі показники (середнє, максимум та мінімум) для щоденних витрат по Google та Facebook окремо.

-- Facebook daily aggregates
with facebook_daily as (
    select 
        ad_date,
        'Facebook Ads' as media_source,
        avg(spend) as avg_daily_spend,
        min(spend) as min_daily_spend,
        max(spend) as max_daily_spend
    from facebook_ads_basic_daily
    group by ad_date
),

-- Google daily aggregates
google_daily as (
    select 
        ad_date,
        'Google Ads' as media_source,
        avg(spend) as avg_daily_spend,
        min(spend) as min_daily_spend,
        max(spend) as max_daily_spend
    from google_ads_basic_daily
    group by ad_date
)

-- Combine all rows into one result
select * from facebook_daily
union all
select * from google_daily
order by ad_date;

---Знайди топ-5 днів за рівнем ROMI загалом (включаючи Google та Facebook),
----виведи дати та відповідні значення в порядку спадання.

with combined_aggregates as (
    select ad_date as daily_date,
           spend as daily_spend,
           value as daily_value
    from facebook_ads_basic_daily

    union all

    select ad_date as daily_date,
           spend as daily_spend,
           value as daily_value
    from google_ads_basic_daily
),
Daily_aggregates as (
    select 
        daily_date,
        sum(daily_spend) as total_spend,
        sum(daily_value) as total_value,
        case 
            when sum(daily_spend) > 0 then sum(daily_value)::numeric / sum(daily_spend) * 100
            else 0
        end as Romi
    from combined_aggregates
    group by daily_date
)
select 
    daily_date as ad_date,
    total_spend,
    total_value,
    Romi
from Daily_aggregates
order by Romi desc
limit 5;

-------Відобрази компанію з найвищим рівнем загального тижневого value (не забудь вказати тиждень та значення рекорду).



with facebook_campaigns as (
    select
        date_trunc('week', fbd.ad_date) as week,
        fa.adset_name as campaign_name,
        sum(fbd.value) as total_value
    from facebook_ads_basic_daily fbd
    join facebook_adset fa on fbd.adset_id = fa.adset_id
    group by 1, 2
),

google_campaigns as (
    select
        date_trunc('week', ad_date) as week,
        campaign_name,
        sum(value) as total_value
    from google_ads_basic_daily
    group by 1, 2
),

all_campaigns as (
    select * from facebook_campaigns
    union all
    select * from google_campaigns
)

select
    week,
    campaign_name,
    total_value
from all_campaigns
order by total_value desc
limit 1;




with Facebook_with_campaing as (

select
fbd.ad_date,
fa.adset_name as campaing_name,
fbd.value
from facebook_ads_basic_daily as fbd
inner join facebook_adset fa on fbd.adset_id = fa.adset_id
),

Google_campaing_name as (
select 
ad_date,
campaign_name,
value
from google_ads_basic_daily
),

Combined_campaings as (
select *
from Facebook_with_campaing
union all 
select *
from Google_campaing_name
),

Weekly_campaing as (
select 
date_trunc('week', ad_date) as week_start,
campaing_name,
sum(value) as total_weekly_value
from Combined_campaings 
group by week_start, campaing_name
)
select 
week_start,
campaing_name,
total_weekly_value
from Weekly_campaing
order by total_weekly_value desc 
limit 1;



----Знайди кампанію, що мала найбільший приріст у охопленні місяць-до місяця.

with Facebook_date as (
select
date_trunc('month', fbd.ad_date ) as month,
fa.adset_name as campaign_name,
sum(fbd.reach) as monthly_reach 
from facebook_ads_basic_daily as fbd 
inner join facebook_adset fa on fbd.adset_id = fa.adset_id
group by date_trunc('month', fbd.ad_date ), campaign_name
order by date_trunc('month', fbd.ad_date )
),

Google_date as (
select 
date_trunc('month', ad_date) as month,
campaign_name,
sum(reach) as monthly_reach 
from google_ads_basic_daily
group by date_trunc('month', ad_date), campaign_name
),

Google_Facebook_combined as (
select *
from Facebook_date
union all 
select * 
from Google_date 
),

reach_month_growth as (
select 
campaign_name,
monthly_reach,
month,
lag(monthly_reach) over (partition by campaign_name order by month) as prev_month_reach,
monthly_reach - lag(monthly_reach) over (partition by campaign_name order by month ) as reach_growth 
from Google_Facebook_combined
)

select 
campaign_name,
month,
prev_month_reach,
monthly_reach,
reach_growth
from reach_month_growth
order by reach_growth desc 
limit 1;


------ Напиши запит, який поверне назву та тривалість найдовшого безперервного 
----(щоденного) показу adset_name (разом з Google та Facebook). (виконання цього підзавдання не обовʼязкове, за бажанням)

with facebook_date_ as (
select 
fbd.ad_date,
fa.adset_name as adset_name 
from facebook_ads_basic_daily as fbd 
inner join facebook_adset fa on fbd.adset_id = fa.adset_id
),

Google_date as (
select 
ad_date, 
campaign_name as adset_name
from google_ads_basic_daily
),

Combined_data as (
select *
from facebook_date_

union all

select * 
from Google_date
),

number_ads as (
select 
adset_name,
ad_date,
row_number() over (partition by adset_name order by ad_date) as Rn
from Combined_data
),

grouped_periods as (
select 
adset_name,
ad_date, 
ad_date - (Rn || 'days')::interval as group_id
from number_ads
),

period_length as (
select  adset_name,
min(ad_date) as start_date,
max(ad_date) as end_date,
count(*) as length_date
from grouped_periods
group by adset_name, group_id
),

longest_period as (
select *,
rank() over ( order by length_date desc ) as rnk
from period_length
)

select 
adset_name,
start_date,
end_date,
length_date
from longest_period
where rnk = 1;




select *
from facebook_ads_basic_daily;

select *
from google_ads_basic_daily;


select *
from facebook_campaign


select *
from facebook_adset; 


































select *
from facebook_adset;

select *
from facebook_campaign;




