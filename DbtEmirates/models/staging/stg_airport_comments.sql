with source as (

    select * from {{ source('raw', 'airport_comments') }}

),

renamed as (

    select
        id::int                                as comment_id,
        thread_ref::bigint                     as thread_id,
        airport_ref::int                       as airport_id,
        airport_ident,
        {{ parse_timestamp('date') }}          as commented_at,
        member_nickname,
        subject,
        body

    from source

)

select * from renamed
