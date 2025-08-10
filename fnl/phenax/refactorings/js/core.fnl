(import-macros {: ?call} :phenax.macros)
(local tsutils (require :phenax.utils.treesitter))
(local text (require :phenax.utils.text))
(local {: not_nil?} (require :phenax.utils.utils))
(local shared (require :phenax.refactorings.shared))

(local js {})

(fn js.add_log_for_selected_text []
  (local node (tsutils.get_node_at_cursor 0))
  (local stmnt (js.get_parent_statement node))
  (when (not_nil? stmnt)
    (local contents (: (text.get_selection_text) :gsub "[\n]*" ""))
    (local (end-row _) (stmnt:end_))
    (local log-text (.. "console.log("
                        (vim.json.encode (.. ":: [" contents "]")) ", " contents
                        ")"))
    (vim.api.nvim_buf_set_lines 0 (+ end-row 1) (+ end-row 1) false
                                [(.. (tsutils.get_node_indentation stmnt)
                                     log-text)])))

(fn js.extract_selected_text_as_value []
  (lambda create_declr [opts]
    (local indent (tsutils.get_node_indentation opts.node))
    (local declr-lines [(.. indent "const " opts.name " = "
                            (. opts.selected_lines 1))])
    (vim.list_extend declr-lines (vim.list_slice opts.selected_lines 2))
    (shared.insert_before_node opts.node declr-lines))
  (shared.extract_selected_text {:create_declaration create_declr
                                 :get_parent_statement js.get_parent_statement}))

(fn js.get_parent_statement [node]
  (local parent (or (tsutils.find_closest_parent_of_type node
                                                         [:statement_block])
                    (tsutils.get_root_node 0)))
  (?call parent :child_with_descendant node))

js
