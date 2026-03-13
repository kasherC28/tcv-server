create table if not exists users (
  id bigserial primary key,
  name varchar(100) not null,
  f_name varchar(100) not null,
  email varchar(255) not null unique,
  password varchar(255) not null,
  role smallint not null default 1,
  status smallint not null default 1,
  contact varchar(20) not null,
  dob varchar(20) not null,
  address varchar(255),
  city varchar(100),
  country varchar(100),
  gender smallint not null,
  recorded bigint not null,
  modified bigint not null
);

create index if not exists idx_users_email on users(email);
create index if not exists idx_users_role on users(role);
create index if not exists idx_users_status on users(status);
