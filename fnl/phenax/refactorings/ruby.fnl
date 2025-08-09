(import-macros {: key! : aucmd! : ?call} :phenax.macros)
(local tsutils (require :phenax.utils.treesitter))
(local core (require :nfnl.core))
(local {: not_nil?} (require :phenax.utils.utils))
(local shared (require :phenax.refactorings.shared))

(local ruby {})

(fn ruby.initialize []
  (aucmd! :FileType {:pattern [:ruby] :callback (fn [] (ruby.setup_current_buf))}))

(fn ruby.setup_current_buf []
  (key! :ia :memoize (fn [] (pcall ruby.include_memery_around_class) :memoize)
        {:buffer true :expr true})
  (key! :ia :def "def\nend<Up>" {:buffer true})
  (key! :ia :context "context 'when' do\nend<Up><c-o>fn<Right>" {:buffer true})
  (key! :ia :it "it 'does' do\nend<Up><c-o>fs<Right>" {:buffer true})
  (key! :ia :let "let(:) { }<c-o>4h" {:buffer true})
  (key! :v :<leader>rev ruby.extract_selected_text_as_method {:buffer true}))

(fn ruby.get_parent_statement [node]
  (local parent (or (tsutils.find_closest_parent_of_type node [:class :module])
                    (tsutils.get_root_node 0)))
  (when (not_nil? parent)
    (var body parent)
    (each [n _ (parent:iter_children)]
      (when (= (n:type) :body_statement)
        (set body n)))
    (?call body :child_with_descendant node)))

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
  (lambda body-statement? [node] (core.println node) (= (node:type) :body_statement))
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
