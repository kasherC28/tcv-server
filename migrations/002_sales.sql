create table if not exists sales (
  id bigserial primary key,
  user_id bigint not null references users(id) on delete cascade,
  transaction varchar(100) not null,
  code varchar(100) not null,
  count integer not null check (count > 0),
  recorded bigint not null,
  modified bigint not null
);

create index if not exists idx_sales_user_id on sales(user_id);
create index if not exists idx_sales_transaction on sales(transaction);
