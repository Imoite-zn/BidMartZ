create table auctions (
  id uuid default uuid_generate_v4() primary key,
  name text not null,
  description text,
  starting_price integer not null,
  current_price integer not null,
  image_url text,
  duration integer not null,
  end_time timestamp with time zone not null,
  status text not null default 'active',
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- Create an index for faster queries
create index auctions_status_idx on auctions(status);

-- Allow public read access to auction images
create policy "Auction images are publicly accessible"
  on storage.objects for select
  using ( bucket_id = 'auction_images' );

-- Allow authenticated users to upload images
create policy "Users can upload auction images"
  on storage.objects for insert
  using ( bucket_id = 'auction_images' );

-- Allow insert access to auctions table
create policy "Anyone can insert auctions"
on auctions for insert
with check (true);

-- Allow read access to auctions
create policy "Anyone can view auctions"
on auctions for select
using (true);
