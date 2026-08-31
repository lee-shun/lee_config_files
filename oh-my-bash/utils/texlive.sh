# texlive（自动探测最新版本目录，如 /usr/local/texlive/2025）
texlive_dir=$(ls -d /usr/local/texlive/2* 2>/dev/null | sort -V | tail -1)
if [ -n "$texlive_dir" ]; then
    export MANPATH=${MANPATH}:${texlive_dir}/texmf-dist/doc/man
    export INFOPATH=${INFOPATH}:${texlive_dir}/texmf-dist/doc/info
    export PATH=${PATH}:${texlive_dir}/bin/x86_64-linux
fi
