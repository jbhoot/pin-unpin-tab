dune build --profile=release
cd _build/default
web-ext build --ignore-files="*.ml" "*.sh" "*.md" dune dune-project "*.zip" "*.bc"