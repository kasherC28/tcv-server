create table if not exists checkout_requests (
  id bigserial primary key,
  user_id bigint not null references users(id) on delete cascade,
  status smallint not null default 1,
  payment_method varchar(40) not null,
  items jsonb not null,
  receipt_sent_whatsapp smallint not null default 0,
  receipt_sent_email smallint not null default 0,
  notes text,
  confirmed_by bigint references users(id) on delete set null,
  confirmed_at bigint,
  recorded bigint not null,
  modified bigint not null
);

create index if not exists idx_checkout_requests_user_id on checkout_requests(user_id);
create index if not exists idx_checkout_requests_status on checkout_requests(status);
