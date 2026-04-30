download_url="https://github.com/PapirusDevelopmentTeam/papirus-icon-theme/archive/refs/tags/20240501.tar.gz"


echo ${download_url}

# 下载最新版本的主题包
echo "Downloading the latest release of ${THEME_NAME}..."
wget -q --show-progress "$download_url" -O "papirus_icon_24_05_01.tar.gz"

# 解压并移动到主题目录
echo "Extracting and installing the theme..."
tar -xvf "papirus_icon_24_05_01.tar.gz"


echo "Download complete."
