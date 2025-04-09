(lang dune 3.16)

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
 (depends
  (ocaml
   (= 5.3.0))
  ;; 5.1.0-53 => melange v5.1.0 linked to ocaml v5.3.x
  (melange
   (= 5.1.0-53))
  reason ; reason-promise in package.json needs it
  utop))

(maintainers "Jayesh Bhoot")

(authors "Jayesh Bhoot")
