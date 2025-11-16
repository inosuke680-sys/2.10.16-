#!/bin/bash

#############################################
# Umaten トップページプラグイン v2.10.18
# 本番環境デプロイスクリプト
#############################################

set -e

echo "=========================================="
echo "Umaten トップページ v2.10.18 デプロイ開始"
echo "=========================================="

# 設定
PLUGIN_NAME="umaten-toppage"
VERSION="2.10.18"
GITHUB_BRANCH="claude/fix-hokkaido-loop-01HNUeZysEdC1xEYB1wps3ih"
GITHUB_BASE_URL="https://raw.githubusercontent.com/inosuke680-sys/2.10.16-/${GITHUB_BRANCH}/umaten-toppage-v2.10.16.backup.20251116_223344"

# WordPress プラグインディレクトリ
WP_PLUGINS_DIR="/home/kusanagi/45515055731ac663c7c3ad4c/DocumentRoot/wp-content/plugins"
PLUGIN_DIR="${WP_PLUGINS_DIR}/${PLUGIN_NAME}"

# 一時ディレクトリ
TEMP_DIR="/tmp/umaten-toppage-v${VERSION}"

echo ""
echo "1. 一時ディレクトリを作成"
rm -rf "${TEMP_DIR}"
mkdir -p "${TEMP_DIR}"
mkdir -p "${TEMP_DIR}/assets/css"
mkdir -p "${TEMP_DIR}/assets/js"
mkdir -p "${TEMP_DIR}/includes"

echo ""
echo "2. GitHubからファイルをダウンロード"

# メインファイル
echo "  - umaten-toppage.php"
curl -sS -o "${TEMP_DIR}/umaten-toppage.php" "${GITHUB_BASE_URL}/umaten-toppage.php"

echo "  - README.md"
curl -sS -o "${TEMP_DIR}/README.md" "${GITHUB_BASE_URL}/README.md"

# CSS
echo "  - assets/css/toppage.css"
curl -sS -o "${TEMP_DIR}/assets/css/toppage.css" "${GITHUB_BASE_URL}/assets/css/toppage.css"

# JavaScript
echo "  - assets/js/toppage.js"
curl -sS -o "${TEMP_DIR}/assets/js/toppage.js" "${GITHUB_BASE_URL}/assets/js/toppage.js"

# PHPクラスファイル
echo "  - includes/class-admin-settings.php"
curl -sS -o "${TEMP_DIR}/includes/class-admin-settings.php" "${GITHUB_BASE_URL}/includes/class-admin-settings.php"

echo "  - includes/class-ajax-handler.php"
curl -sS -o "${TEMP_DIR}/includes/class-ajax-handler.php" "${GITHUB_BASE_URL}/includes/class-ajax-handler.php"

echo "  - includes/class-hero-image.php"
curl -sS -o "${TEMP_DIR}/includes/class-hero-image.php" "${GITHUB_BASE_URL}/includes/class-hero-image.php"

echo "  - includes/class-search-results.php"
curl -sS -o "${TEMP_DIR}/includes/class-search-results.php" "${GITHUB_BASE_URL}/includes/class-search-results.php"

echo "  - includes/class-seo-meta.php"
curl -sS -o "${TEMP_DIR}/includes/class-seo-meta.php" "${GITHUB_BASE_URL}/includes/class-seo-meta.php"

echo "  - includes/class-shortcode.php"
curl -sS -o "${TEMP_DIR}/includes/class-shortcode.php" "${GITHUB_BASE_URL}/includes/class-shortcode.php"

echo "  - includes/class-url-rewrite.php"
curl -sS -o "${TEMP_DIR}/includes/class-url-rewrite.php" "${GITHUB_BASE_URL}/includes/class-url-rewrite.php"

echo "  - includes/class-view-counter.php"
curl -sS -o "${TEMP_DIR}/includes/class-view-counter.php" "${GITHUB_BASE_URL}/includes/class-view-counter.php"

echo ""
echo "3. ダウンロードしたファイルを検証"
if [ ! -f "${TEMP_DIR}/umaten-toppage.php" ]; then
    echo "エラー: メインファイルのダウンロードに失敗しました"
    exit 1
fi

if [ ! -f "${TEMP_DIR}/assets/js/toppage.js" ]; then
    echo "エラー: JavaScriptファイルのダウンロードに失敗しました"
    exit 1
fi

if [ ! -f "${TEMP_DIR}/includes/class-ajax-handler.php" ]; then
    echo "エラー: AJAXハンドラーのダウンロードに失敗しました"
    exit 1
fi

# バージョン確認
VERSION_IN_FILE=$(grep "Version:" "${TEMP_DIR}/umaten-toppage.php" | head -n 1 | sed 's/.*Version: //' | sed 's/ *$//')
if [ "$VERSION_IN_FILE" != "$VERSION" ]; then
    echo "警告: バージョンが一致しません (期待: ${VERSION}, 実際: ${VERSION_IN_FILE})"
fi

echo ""
echo "4. 既存のプラグインディレクトリをバックアップ"
if [ -d "${PLUGIN_DIR}" ]; then
    BACKUP_DIR="${WP_PLUGINS_DIR}/${PLUGIN_NAME}.backup.$(date +%Y%m%d_%H%M%S)"
    echo "  バックアップ先: ${BACKUP_DIR}"
    cp -r "${PLUGIN_DIR}" "${BACKUP_DIR}"
else
    echo "  既存のプラグインが見つかりません。新規インストールします。"
    mkdir -p "${PLUGIN_DIR}"
fi

echo ""
echo "5. 新しいファイルをデプロイ"
# includesとassetsディレクトリを削除して置き換え
rm -rf "${PLUGIN_DIR}/includes"
rm -rf "${PLUGIN_DIR}/assets"

# 新しいファイルをコピー
cp -r "${TEMP_DIR}"/* "${PLUGIN_DIR}/"

# パーミッション設定
chown -R kusanagi:www "${PLUGIN_DIR}"
find "${PLUGIN_DIR}" -type f -exec chmod 644 {} \;
find "${PLUGIN_DIR}" -type d -exec chmod 755 {} \;

echo ""
echo "6. 一時ディレクトリを削除"
rm -rf "${TEMP_DIR}"

echo ""
echo "=========================================="
echo "デプロイ完了: v${VERSION}"
echo "=========================================="
echo ""
echo "次のステップ:"
echo "1. WordPress管理画面 → プラグイン"
echo "2. プラグインが無効化されている場合は有効化"
echo "3. 設定 → パーマリンク → 「変更を保存」をクリック"
echo ""
echo "動作確認:"
echo "1. 北海道エリアを選択 → 北海道を選択 → 札幌市、函館市などが表示されることを確認"
echo "2. ループしないことを確認"
echo "3. 他のエリアも正常に動作することを確認"
echo ""
