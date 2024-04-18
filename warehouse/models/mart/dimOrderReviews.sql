select
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp,
    dbt_updated_at,
    dbt_valid_from,
    dbt_valid_to

from {{ ref('stg_order_reviews') }}