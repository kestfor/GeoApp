CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

create table if not exists event
(
    id          uuid primary key default uuid_generate_v4(),
    owner_id    uuid not null,
    name        text not null,
    description text,
    latitude    numeric(10, 6),
    longitude   numeric(10, 6),
    created_at  timestamptz      default now(),
    updated_at  timestamptz      default now()
);

create table if not exists event_participant
(
    event_id       uuid references event (id) on delete cascade,
    participant_id uuid not null
        primary key (event_id, participant_id)
);

create index if not exists idx_event_participant_participant_id on event_participant (participant_id);

create table if not exists event_media
(
    event_id uuid references event (id) on delete cascade,
    media_id uuid not null,
    primary key (event_id, media_id)
);

create table if not exists comment
(
    id         uuid primary key default uuid_generate_v4(),
    event_id   uuid not null references event (id) on delete cascade,
    author_id  uuid not null,
    text       text not null,
    created_at timestamptz      default now(),
    updated_at timestamptz      default now()
);
