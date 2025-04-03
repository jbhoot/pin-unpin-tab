(lang dune 3.8)

(using melange 0.1)

(using directory-targets 0.1)

(generate_opam_files true)

(package
 (name pin-unpin-tab)
 (synopsis "Firefox add-on to pin/unpin a tab")
 (description
  "Firefox add-on to pin or unpin a tab through a toolbar icon, or a keyboard shortcut, or a left long-click anywhere on the page.")
 (homepage "https://github.com/jyshb/pin-unpin-tab")
 (bug_reports "https://github.com/jyshb/pin-unpin-tab/issues")
 (allow_empty)
 ; (depends (melange (>= 1.0.0)) (ocaml-lsp-server :with-dev-setup) (utop :with-dev-setup) (ocamlformat :with-dev-setup)))
 (depends
  (melange
   (and (>= 1.0.0)  (<= 1.0.0)) )
  reason ; reason-promise needs it
  ocaml-lsp-server
  utop
  ocamlformat))

(maintainers "Jayesh Bhoot")

(authors "Jayesh Bhoot")
