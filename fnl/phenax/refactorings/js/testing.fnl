(import-macros {: key! : aucmd! : ?call} :phenax.macros)
(local tsutils (require :phenax.utils.treesitter))
(local core (require :nfnl.core))
(local {: not_nil? : index-of} (require :phenax.utils.utils))

(local js {:test_block_states [:it :it.only]})

(fn js.toggle_it []
  (local buf 0)
  (lambda call_expr? [node] (vim.tbl_contains [:call_expression] (node:type)))
  (lambda func_node [node] (-> (node:field :function) (core.first)))
  (lambda test_block? [node]
    (and (call_expr? node)
         (js.test_block_name? (tsutils.->text (func_node node) buf))))
  (local node (tsutils.get_node_at_cursor buf))
  (local block (tsutils.find_closest_parent node test_block?))
  (when (not_nil? block)
    (local ident (func_node block))
    (local new_func_name
           (-> ident (tsutils.->text buf) js.next_text_block_state))
    (tsutils.replace_node_with_text buf ident [new_func_name])))

(fn js.test_block_name? [it]
  (and (not_nil? it) (or (= it :it) (string.match it :^it.))))

(fn js.next_text_block_state [it]
  (local it_index (or (index-of it js.test_block_states) 0))
  (local next_index (core.inc (% it_index (length js.test_block_states))))
  (. js.test_block_states next_index))

js
