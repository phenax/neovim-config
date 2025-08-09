(local tsutils (require :phenax.utils.treesitter))
(local core (require :nfnl.core))
(local {: not_nil?} (require :phenax.utils.utils))

(local ruby {})

(fn ruby.include_memery_around_class []
  (local node (tsutils.get_node_at_cursor))
  (local class-node (tsutils.find_closest_parent_of_type node [:class]))
  (when (not_nil? class-node)
    (local buf (vim.api.nvim_get_current_buf))
    (vim.schedule (fn [] (ruby.include_memery_in_class_node buf class-node)))))

(fn ruby.include_memery_in_class_node [buf class-node]
  (local (start-row _ _) (class-node:start))
  (when (not (ruby.includes_memery? buf class-node))
    (local indent (tsutils.get_node_indentation class-node))
    (vim.api.nvim_buf_set_lines buf (+ start-row 1) (+ start-row 1) false
                                [(.. indent "include Memery")])))

(fn ruby.includes_memery? [buf class-node]
  (lambda body-statement? [node] (= (node:type) :body_statement))
  (lambda text-includes-memory? [node]
    (-> (vim.treesitter.get_node_text node buf)
        (string.match "include%s+Memery")))
  (lambda is-body-statement-with-memery? [node]
    (and (body-statement? node) (text-includes-memory? node)))
  ;; Check if body statement includes `include Memoize`
  (->> (: (vim.iter (class-node:iter_children)) :totable)
       (core.some (fn [[node] _]
                    (is-body-statement-with-memery? node)))))

ruby
