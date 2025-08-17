(import-macros {: key! : cmd! : let*} :phenax.macros)
(local core (require :nfnl.core))
(local str (require :nfnl.string))
(local qf (require :phenax.quickfix))
(local {: slice_list : split_lines : join_lines : ++}
       (require :phenax.utils.utils))

(local github {:preview-type :gh-review-comments})

(fn github.initialize []
  (cmd! :GhPRCreate (fn [opts] (github.create-pr opts.fargs)) {:nargs "*"})
  (cmd! :GhPRComments github.show-gh-reviews {})
  (cmd! :GhPRList github.pick-prs {})
  (qf.add-item-previewer github.preview-type github.preview-qf-review-item))

(fn github.pick-prs []
  (lambda confirm [picker item]
    (picker:close)
    (vim.notify (.. "Switching to #" item.number))
    (vim.cmd (.. "!gh co " item.url)))
  (lambda preview [ctx]
    (ctx.preview:highlight {:ft :markdown})
    (ctx.preview:set_lines [(.. "# " ctx.item.title) "" ctx.item.body]))
  (lambda format [item]
    (local {: align : truncate} Snacks.picker.util)
    (local review-requested?
           (core.some (fn [p] (= p.login :phenax)) item.reviewRequests))
    [[(align (if review-requested? :R "") 2)]
     [(align (if item.isDraft :D "") 2)]
     [(align (.. "#" item.number) 7)]
     [(align (truncate item.title 69) 70)]
     [item.author.login]])
  (lambda text [p] (.. p.number " " p.title " " p.author.login))
  (lambda ->item [p]
    (++ p {:text (text p)}))
  (lambda show-picker [items]
    (Snacks.picker.pick {: confirm
                         : format
                         : preview
                         : items
                         :title "Pull requests"}))
  (let* [prs (github.fetch-open-prs)]
        (vim.schedule (fn []
                        (local items (vim.tbl_map ->item prs))
                        (show-picker items)))))

(fn github.create-pr [args]
  (local cmd "echo \"Creating PR (args: $@)...\";
    if [ -f '.github/pull_request_template.md' ]; then
      gh pr create -e -a '@me' -T 'pull_request_template.md' \"$@\";
    else
      gh pr create -e -a '@me' \"$@\";
    fi || true;
    url=\"$(gh pr view --json url -q .url)\";
    [ -z \"$url\" ] && xdg-open \"$url\";")
  (Snacks.terminal.open (vim.list_extend [:sh :-c cmd :gh-create-pr] args)
                        {:interactive false
                         :win {:style :phenax_git_diff
                               :position :bottom
                               :height 35}}))

(fn github.preview-qf-review-item [qfitem _index]
  (local review qfitem.user_data)
  (lambda open-in-browser [] (vim.ui.open review.url))
  (Snacks.win {:style :split
               :text (github.get-review-preview-text review)
               :fixbuf true
               :wo {:wrap true}
               :bo {:filetype :markdown :modifiable false}
               :keys {:q :close :o open-in-browser}}))

(fn github.get-review-preview-text [review]
  (local path_line
         (.. (or review.path :<?path>) (if review.line (.. ":" review.line) "")))
  (local diff_text (-> (or review.diff "") split_lines (slice_list -5)
                       join_lines))
  (local diff (.. "```diff\n" diff_text "\n```"))
  (local comments (->> review.comments
                       (core.map (fn [c]
                                   (.. "## Reply from: @" c.user "\n" c.body)))
                       (str.join "\n\n")))
  (local sections [(.. "# @" (or review.user "<?>") "\n" path_line "\n" diff)
                   (or review.body "")
                   comments
                   (or review.url "<?>")])
  (str.join "\n\n" sections))

(fn github.review->review-userdata [review]
  {:preview_type github.preview-type
   :id review.id
   :in_reply_to_id review.in_reply_to_id
   :url review.html_url
   :diff review.diff_hunk
   :line review.line
   :path review.path
   :comments []
   :resolved? (?. review :state :isResolved)
   :body review.body
   :user review.user.login})

(fn github.reviews->qf-list-items [reviews]
  (local results {})
  (local review_map {})
  (each [_ review-raw (ipairs reviews)]
    (local review (github.review->qf-item review-raw))
    (tset review_map review-raw.id review)
    (if (core.nil? review-raw.in_reply_to_id)
        (table.insert results review)
        (let [parent (. review_map review-raw.in_reply_to_id)]
          (when (?. parent :user_data)
            (table.insert parent.user_data.comments review.user_data)))))
  results)

;; fnlfmt: skip
(fn github.show-gh-reviews []
  (local pr (github.current-pr))
  (if (core.nil? pr)
      (vim.notify "No PR found" vim.log.levels.ERROR)
      (do
        (local repo (.. pr.headRepositoryOwner.login :/ pr.headRepository.name))
        (local pr-number pr.number)
        (vim.notify (.. "Loading comments for PR " repo " #" pr-number) vim.log.levels.INFO)
        ;; TODO: Do these in parallel
        (let* [comments (github.fetch-pr-review-comments repo pr-number)]
          (let* [comments-state (github.fetch-pr-review-comments-state repo pr-number)]
            (each [_ c (ipairs comments)]
              (set c.state (. comments-state (tostring c.id))))
            (github.populate-qflist comments))))))

(fn github.populate-qflist [review-comments]
  (lambda update-qflist []
    (-> review-comments github.reviews->qf-list-items vim.fn.setqflist))
  (vim.schedule (fn [] (update-qflist) (vim.cmd.copen))))

(fn github.review->qf-item [review]
  (local body review.body)
  (local trimmed_body
         (.. (string.sub body 0 60) (if (> (length body) 60) "…" "")))
  (local review_userdata (github.review->review-userdata review))
  (local resolved (if review_userdata.resolved? "[RESOLVED] " ""))
  {:col 0
   :filename review_userdata.path
   :lnum (tonumber review_userdata.line)
   :text (.. resolved "@" review_userdata.user ": " trimmed_body)
   :type (if review_userdata.resolved? :I :E)
   :user_data review_userdata})

;; fnlfmt: skip
(fn github.fetch-open-prs [on-done]
  (local cmd [:gh :pr :list :--json "title,url,author,number,body,isDraft,reviewRequests"])
  (let* [result (vim.system cmd {:text true})]
        (if (= result.code 0)
            (on-done (vim.json.decode result.stdout))
            (vim.notify (.. "Unable to fetch prs: " result.stderr) vim.log.levels.ERROR)))
  )

(fn github.fetch-pr-review-comments [repo pr on_done]
  (local api (.. :/repos/ repo :/pulls/ pr :/comments :?per_page=200))
  (let* [result (vim.system [:gh :api api] {:text true})]
        (if (= result.code 0)
            (on_done (vim.json.decode result.stdout {:luanil {:object true}}))
            (vim.notify (.. "Unable to fetch reviews: " result.stderr)
                        vim.log.levels.ERROR))))

;; fnlfmt: skip
(fn github.current-pr []
  (local result (: (vim.system [:gh :pr :view :--json "number,headRepository,headRepositoryOwner"] {:text true}) :wait))
  (when (= result.code 0)
    (vim.json.decode (or result.stdout "") {:luanil {:object true}})))

;; fnlfmt: skip
(fn pr-review-query [repo pr]
  (local [owner name] (str.split repo "/"))
  (.. "query {
    repository(owner: " (vim.inspect owner) ", name: " (vim.inspect name) ") {
      pullRequest(number: " pr ") {
        reviewThreads(first: 100) { nodes { isResolved comments(first: 1) { nodes { fullDatabaseId } } } } } } }"))

(fn github.fetch-pr-review-comments-state [repo pr on_done]
  (local q (pr-review-query repo pr))
  (lambda on-exit [result]
    (local resp (vim.json.decode result.stdout {:luanil {:object true}}))
    (local threads resp.data.repository.pullRequest.reviewThreads.nodes)
    (local results {})
    (each [_ thread (ipairs threads)]
      (local id (. thread :comments :nodes 1 :fullDatabaseId))
      (tset results (tostring id) thread))
    (on_done results))
  (let* [result
         (vim.system [:gh :api :graphql :--field (.. :query= q)] {:text true})]
        (if (= result.code 0)
            (on-exit result)
            (on_done {}))))

github
