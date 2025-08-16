(import-macros {: key! : cmd! : aucmd! : augroup!} :phenax.macros)
(local core (require :nfnl.core))
(local str (require :nfnl.string))
(local qf (require :phenax.quickfix))
(local {: slice_list : split_lines : join_lines} (require :phenax.utils.utils))

(local github {})

(fn github.initialize []
  (cmd! :GHReviewComments github.show-gh-reviews {})
  (qf.add-item-previewer :gh-review-comments github.preview-qf-review-item))

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
  {:preview_type :gh-review-comments
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
        (lambda with-results [comments comments-state]
          (each [_ c (ipairs comments)]
            (set c.state (. comments-state (tostring c.id))))
          (github.populate-qflist comments))
        ;; TODO: Do these in parallel
        (github.fetch-pr-review-comments repo pr-number (fn [comments]
          (github.fetch-pr-review-comments-state repo pr-number
            (fn [comments-state] (with-results comments comments-state))))))))

(fn github.populate-qflist [review-comments]
  (lambda update-qflist []
    (-> review-comments
        github.reviews->qf-list-items
        (vim.fn.setqflist :r)))
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

(fn github.fetch-pr-review-comments [repo pr on_done]
  (local api (.. :/repos/ repo :/pulls/ pr :/comments :?per_page=200))
  (lambda on-exit [result]
    (if (= result.code 0)
        (on_done (vim.json.decode result.stdout {:luanil {:object true}}))
        (vim.notify (.. "Unable to fetch reviews. Status:" result.code)
                    vim.log.levels.ERROR)))
  (vim.system [:gh :api api] {:text true} on-exit))

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
    (if (not= result.code 0)
        (on_done {})
        (do
          (local resp (vim.json.decode result.stdout {:luanil {:object true}}))
          (local threads resp.data.repository.pullRequest.reviewThreads.nodes)
          (local results {})
          (each [_ thread (ipairs threads)]
            (local id (. thread :comments :nodes 1 :fullDatabaseId))
            (tset results (tostring id) thread))
          (on_done results))))
  (vim.system [:gh :api :graphql :--field (.. :query= q)] {:text true} on-exit))

github
