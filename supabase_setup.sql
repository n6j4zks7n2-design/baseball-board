-- ============================================================
-- 草野球マッチングボード 用 Supabase セットアップSQL
-- 手順：Supabase でプロジェクト作成 → SQL Editor を開く → この内容を貼り付けて実行
-- ============================================================

-- 1. 募集テーブル
create table if not exists public.posts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  author_email text not null,
  type text not null,
  team text not null,
  position text not null,
  exp text not null,
  goal text not null,
  cost text not null,
  area text not null,
  date text not null,
  comment text not null,
  created_at timestamptz not null default now()
);

-- 2. プレイヤー（応募）テーブル
create table if not exists public.players (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  exp text not null,
  position text not null,
  created_at timestamptz not null default now()
);

-- 3. 通報テーブル
create table if not exists public.reports (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts(id) on delete cascade,
  reporter_id uuid not null references auth.users(id) on delete cascade,
  reason text not null,
  created_at timestamptz not null default now()
);

-- インデックス（検索・並び順の高速化）
create index if not exists posts_created_idx on public.posts (created_at desc);
create index if not exists posts_area_idx on public.posts (area);
create index if not exists reports_post_idx on public.reports (post_id);

-- ============================================================
-- 4. Row Level Security（RLS）を有効化
-- ============================================================
alter table public.posts enable row level security;
alter table public.players enable row level security;
alter table public.reports enable row level security;

-- ============================================================
-- 5. ポリシー定義（いたずら対策の中核）
-- ============================================================

-- posts：誰でも閲覧できる
drop policy if exists "posts 誰でも閲覧可" on public.posts;
create policy "posts 誰でも閲覧可" on public.posts
  for select using (true);

-- posts：ログイン済みユーザーのみ投稿できる
drop policy if exists "posts 認証ユーザーは投稿可" on public.posts;
create policy "posts 認証ユーザーは投稿可" on public.posts
  for insert with check (auth.uid() = user_id);

-- posts：投稿者本人のみ削除できる（他人の投稿は削除不可）
drop policy if exists "posts 投稿者本人のみ削除可" on public.posts;
create policy "posts 投稿者本人のみ削除可" on public.posts
  for delete using (auth.uid() = user_id);

-- posts：編集（update）は本人のみ（今回は更新機能なしだが、念のため）
drop policy if exists "posts 投稿者本人のみ更新可" on public.posts;
create policy "posts 投稿者本人のみ更新可" on public.posts
  for update using (auth.uid() = user_id);

-- players：誰でも閲覧できる
drop policy if exists "players 誰でも閲覧可" on public.players;
create policy "players 誰でも閲覧可" on public.players
  for select using (true);

-- players：認証ユーザーのみ登録できる
drop policy if exists "players 認証ユーザーは登録可" on public.players;
create policy "players 認証ユーザーは登録可" on public.players
  for insert with check (auth.uid() = user_id);

-- reports：認証ユーザーのみ通報できる
drop policy if exists "reports 認証ユーザーは通報可" on public.reports;
create policy "reports 認証ユーザーは通報可" on public.reports
  for insert with check (auth.uid() = reporter_id);

-- reports：管理者のみ閲覧（一般ユーザーには見せない）
drop policy if exists "reports 管理者のみ閲覧可" on public.reports;
create policy "reports 管理者のみ閲覧可" on public.reports
  for select using (false);

-- ============================================================
-- 6. （参考）Supabase 側の設定メモ
-- ============================================================
-- Authentication > Providers > Email を有効化。
--   - "Confirm email" を ON にすると、新規登録後に確認メールが送られ、
--     本人確認済みのユーザーのみ投稿できる（いたずら対策に推奨）。
--   確認済みユーザーのみ書けるようにしたい場合は、insert ポリシーを以下に変更：
--     with check (auth.uid() = user_id and auth.jwt() ->> 'email_confirmed_at' is not null)
-- Authentication > Rate Limits で、登録・ログインの試行回数を制限できる。
