(import-macros {: key! : aucmd! : ?call} :phenax.macros)
(local tsutils (require :phenax.utils.treesitter))
(local text (require :phenax.utils.text))
(local {: not_nil?} (require :phenax.utils.utils))
(local shared (require :phenax.refactorings.shared))

(local js {})

(fn js.initialize []
  (aucmd! :FileType
          {:pattern [:javascript :typescript :javascriptreact :typescriptreact]
           :callback (fn [] (js.setup_current_buf))}))

(fn js.setup_current_buf []
  (key! :ia :await (fn [] (pcall js.wrap_async_around_closest_function) :await)
        {:buffer true :expr true})
  (key! :ia :describe "describe('when', () => {\n})<Up><c-o>fn<Right>"
        {:buffer true})
  (key! :ia :it "it('does', () => {\n})<Up><c-o>fs<Right>" {:buffer true})
  (key! :v :<leader>rll js.add_log_for_selected_text {:buffer true})
  (key! :v :<leader>rev js.extract_selected_text_as_value {:buffer true}))

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

(fn js.wrap_async_around_closest_function []
  (local node (tsutils.get_node_at_cursor))
  (local parent-func (js.find_closest_parent_func node))
  (when (not_nil? parent-func)
    (local buf (vim.api.nvim_get_current_buf))
    (vim.schedule (fn [] (pcall js.add_async_around_node buf parent-func)))))

(fn js.add_async_around_node [buf func-node]
  (local (start-row start-col _) (func-node:start))
  (local line (. (vim.api.nvim_buf_get_lines buf start-row (+ start-row 1)
                                             false) 1))
  (local has_async_keyword?
         (-> line
             (string.sub (+ start-col 1))
             (string.match "^%s*async%s+")))
  (when (not has_async_keyword?)
    (local asynced-line (.. (line:sub 1 start-col) "async "
                            (line:sub (+ start-col 1))))
    (vim.api.nvim_buf_set_lines buf start-row (+ start-row 1) false
                                [asynced-line])))

(fn js.get_parent_statement [node]
  (local parent (or (tsutils.find_closest_parent_of_type node
                                                         [:statement_block])
                    (tsutils.get_root_node 0)))
  (?call parent :child_with_descendant node))

(fn js.find_closest_parent_func [node]
  (tsutils.find_closest_parent_of_type node
                                       [:function_expression
                                        :function_declaration
                                        :arrow_function
                                        :method_definition]))

js
