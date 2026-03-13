create table if not exists password_otps (
  id bigserial primary key,
  user_id bigint not null references users(id) on delete cascade,
  otp_hash varchar(255) not null,
  expires_at bigint not null,
  used smallint not null default 0,
  attempts integer not null default 0,
  recorded bigint not null,
  modified bigint not null
);

create index if not exists idx_password_otps_user_id on password_otps(user_id);
create index if not exists idx_password_otps_expires_at on password_otps(expires_at);
