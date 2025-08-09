(import-macros {: key! : aucmd! : ?call} :phenax.macros)
(local tsutils (require :phenax.utils.treesitter))
(local {: not_nil?} (require :phenax.utils.utils))

(local js {})

(fn js.wrap_async_around_closest_function []
  (fn add-async [buf func-node]
    (local (start-row start-col _) (func-node:start))
    (local line (. (vim.api.nvim_buf_get_lines buf start-row (+ start-row 1)
                                               false) 1))
    (local has_async_keyword?
           (-> line
               (string.sub (+ start-col 1))
               (string.match "^%s*async%s+")))
    (when (not has_async_keyword?)
      (local asynced-line
             (.. (line:sub 1 start-col) "async " (line:sub (+ start-col 1))))
      (vim.api.nvim_buf_set_lines buf start-row (+ start-row 1) false
                                  [asynced-line])))

  (local node (tsutils.get_node_at_cursor))
  (local parent-func (js.find_closest_parent_func node))
  (when (not_nil? parent-func)
    (local buf (vim.api.nvim_get_current_buf))
    (vim.schedule (fn [] (pcall add-async buf parent-func)))))

(fn js.find_closest_parent_func [node]
  (tsutils.find_closest_parent_of_type node
                                       [:function_expression
                                        :function_declaration
                                        :arrow_function
                                        :method_definition]))

js
