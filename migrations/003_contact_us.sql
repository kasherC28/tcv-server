create table if not exists contact_us (
  id bigserial primary key,
  name varchar(100) not null,
  email varchar(255) not null,
  contact varchar(20) not null,
  subject smallint not null default 1,
  message text not null,
  recorded bigint not null,
  modified bigint not null
);

create index if not exists idx_contact_us_email on contact_us(email);
create index if not exists idx_contact_us_subject on contact_us(subject);
