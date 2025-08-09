(local tsutils (require :phenax.utils.treesitter))
(local text (require :phenax.utils.text))
(local {: nil?} (require :nfnl.core))
(local {: present?} (require :phenax.utils.utils))

(local shared {})

(lambda shared.extract_selected_text [opts]
  (set opts.name_prompt (or opts.name_prompt :Name))
  (local node (tsutils.get_node_at_cursor 0))
  (when (nil? node) (lua "return "))
  (local (start-row start-col end-row end-col) (text.get_selection_range))
  (local lines (text.get_selection_lines))
  (local stmnt (opts.get_parent_statement (node:parent)))
  (when (nil? stmnt) (lua "return "))
  (local val-name (vim.fn.input (.. opts.name_prompt ": ")))
  (when (present? val-name)
    (vim.api.nvim_buf_set_text 0 (- start-row 1) (- start-col 1) (- end-row 1)
                               end-col [val-name])
    (opts.create_declaration {:name val-name :node stmnt :selected_lines lines})))

(fn shared.insert_before_node [node lines]
  (local (stmnt-start-row _) (node:start))
  (vim.api.nvim_buf_set_lines 0 stmnt-start-row stmnt-start-row false lines))

(fn shared.insert_after_node [node lines offset-lines]
  (local (stmnt-end-row _) (node:end_))
  (vim.api.nvim_buf_set_lines 0 (+ stmnt-end-row offset-lines 1)
                              (+ stmnt-end-row offset-lines 1) false lines))

shared
