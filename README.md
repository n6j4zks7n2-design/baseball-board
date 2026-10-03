# 草野球マッチングボード ⚾

草野球チームの「助っ人・対戦相手・メンバー」募集を、気軽につなぐマッチングアプリ（Web）。

## 機能

- 募集の投稿（種別・チーム名・募集ポジション・求める最終経験・チームのレベル/目標・費用・都道府県・日時・コメント）
- 絞り込み（種別・地域・レベル/目標・ポジション）
- プレイヤー登録（応募サイド：ニックネーム・最終経験・ポジション）
- いたずら対策：メールでサインアップ/ログイン、投稿はログイン必須、投稿は本人のみ削除可、通報、連投制限

## 構成

- `index.html` — フロントエンド一式（HTML/CSS/JavaScript、依存なし＝単一ファイル）
- `supabase_setup.sql` — Supabase用のテーブル＋RLS（Row Level Security）設定

## 動作モード

| モード | 条件 | 内容 |
|---|---|---|
| デモモード | 初期状態 | ブラウザ内（localStorage）で認証フローを確認できる。本物の認証ではない |
| 本番モード | Supabaseキー設定後 | 実認証＋実DBで動作 |

本番モードへの切替は、`index.html` 冒頭の `SUPABASE_URL` と `SUPABASE_ANON_KEY` を入力するだけ。

## デプロイ手順

1. **フロント公開（GitHub Pages）**
   - このリポジトリをGitHubにpush
   - Settings > Pages で「Deploy from a branch」→ main / root を選択
   - `https://<user名>.github.io/<リポジトリ名>/` で公開される

2. **バックエンド（Supabase）**
   - [supabase.com](https://supabase.com) でプロジェクト作成（GitHubログイン可）
   - SQL Editor で `supabase_setup.sql` を実行
   - Authentication > Providers > Email を有効化（確認メールON推奨）
   - プロジェクトの URL / anon key を `index.html` に入力

## 注意

- デモモードの認証は動作確認用であり、本物のセキュリティはありません。実際に人に使ってもらう場合は必ず本番モード（Supabase）で運用してください。
- いたずら・誹謗中傷等には、通報と運営による削除で対処する前提の設計です。
