(import-macros {: key!} :phenax.macros)
(local core (require :nfnl.core))
(local {: present?} (require :phenax.utils.utils))

(local picker-history {:max_cached_pickers 20
                       :name :history_picker
                       :pickers {}})

(fn picker-history.initialize []
  (key! :n :<leader>tp (fn [] (picker-history.open))))

(fn picker-history.save_picker [picker]
  (when (= picker.opts.source picker-history.name) (lua "return "))
  (set picker.opts.pattern picker.finder.filter.pattern)
  (set picker.opts.search picker.finder.filter.search)
  (when (>= (length picker-history.pickers) picker-history.max_cached_pickers)
    (table.remove picker-history.pickers picker-history.max_cached_pickers))
  (table.insert picker-history.pickers 1 picker.opts))

(fn picker-history.open []
  (Snacks.picker.pick {:confirm (fn [picker item]
                                  (picker-history.confirm picker item))
                       :finder (fn [] (picker-history.finder))
                       :format (fn [item _] (picker-history.format item))
                       :preview (fn [ctx] (picker-history.preview ctx))
                       :source picker-history.name
                       :title :History}))

(fn picker-history.finder []
  (core.map (fn [picker] {:picker_opts picker}) picker-history.pickers))

(fn picker-history.format [item _]
  (local source (or item.picker_opts.source "unknown source"))
  (local pattern (or item.picker_opts.pattern ""))
  (local search (or item.picker_opts.search ""))
  [[(Snacks.picker.util.align source 30)]
   [(.. pattern (if (present? search) (.. " > " search) ""))]])

(fn picker-history.preview [ctx]
  (local source (or ctx.item.picker_opts.source :unknown))
  (local pattern (or ctx.item.picker_opts.pattern ""))
  (ctx.preview:set_title source)
  (ctx.preview:set_lines [(.. "Source: " source) (.. "Pattern: " pattern)])
  (ctx.preview:highlight {:ft :yaml}))

(fn picker-history.confirm [picker ?item]
  (picker:close)
  (when (present? ?item)
    (local old-picker (Snacks.picker.pick ?item.picker_opts))
    (old-picker.list:update)
    (old-picker.input:update)))

picker-history
