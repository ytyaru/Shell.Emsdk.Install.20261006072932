#!/bin/bash

# エラーが発生した時点でスクリプトを停止する
set -e

# スクリプトが存在するディレクトリに移動
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== 1. 必要なパッケージの確認・更新 ==="
if ! command -v git &> /dev/null; then
    echo "gitが見つかりません。インストールします..."
    sudo apt-get update && sudo apt-get install -y git
fi

if ! command -v python3 &> /dev/null; then
    echo "python3が見つかりません。インストールします..."
    sudo apt-get update && sudo apt-get install -y python3
fi

echo "=== 2. emsdkリポジトリのクローン（または更新） ==="
if [ -d "emsdk" ]; then
    echo "emsdkディレクトリが既に存在します。最新の状態に更新します..."
    cd emsdk
    git pull
else
    echo "emsdkをクローンしています..."
    git clone https://github.com/emscripten-core/emsdk.git
    cd emsdk
    # 初回クローン時は既に最新なのでgit pullは不要
fi

echo "=== 3. 最新安定版（Latest Stable）の特定とインストール ==="
# 公式推奨の「latest」タグ（常に最新の安定版を指すエイリアス）を使用します
# または、emsdkのコマンドで確実に安定版をインストールします。
TARGET_VERSION="latest"

echo "最新安定版 (${TARGET_VERSION}) をインストールします..."

# emsdk自体を最新の状態にする代わりに、gitで最新に追従させる
git pull

# 安定版のインストールとアクティベート
./emsdk install ${TARGET_VERSION}
./emsdk activate ${TARGET_VERSION}

echo "=== 4. セットアップ完了 ==="
echo "以下のコマンドを実行して、環境変数（PATHなど）を現在のシェルに反映させてください："
echo ""
echo "  source \"${SCRIPT_DIR}/emsdk/emsdk_env.sh\""
echo ""
echo "永続的に反映させる場合は、~/.bashrc の末尾に以下を追加してください："
echo "  source \"${SCRIPT_DIR}/emsdk/emsdk_env.sh\""
