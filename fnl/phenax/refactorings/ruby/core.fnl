(import-macros {: ?call} :phenax.macros)
(local tsutils (require :phenax.utils.treesitter))
(local {: not_nil?} (require :phenax.utils.utils))
(local shared (require :phenax.refactorings.shared))

(local ruby {})

(fn ruby.extract_selected_text_as_method []
  (lambda create_declr [opts]
    (local indent (tsutils.get_node_indentation opts.node))
    (local declr-lines ["" (.. indent "def " opts.name)])
    (vim.list_extend declr-lines opts.selected_lines)
    (table.insert declr-lines (.. indent :end))
    (shared.insert_after_node opts.node declr-lines
                              (+ (- (length opts.selected_lines)) 1)))
  (shared.extract_selected_text {:create_declaration create_declr
                                 :get_parent_statement ruby.get_parent_statement}))

(fn ruby.get_parent_statement [node]
  (local parent (or (tsutils.find_closest_parent_of_type node [:class :module])
                    (tsutils.get_root_node 0)))
  (when (not_nil? parent)
    (var body parent)
    (each [n _ (parent:iter_children)]
      (when (= (n:type) :body_statement)
        (set body n)))
    (?call body :child_with_descendant node)))

ruby
