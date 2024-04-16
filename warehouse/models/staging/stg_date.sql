with date_dim as (


{{ dbt_date.get_date_dimension("2016-09-01", "2018-11-30") }}

)
select
    *
from date_dim