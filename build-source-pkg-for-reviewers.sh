zip -r src-pkg.zip.tmp * -x '*.DS_Store*' '*_build*'
rm -rf src-pkg.zip
mv src-pkg.zip.tmp src-pkg.zip
