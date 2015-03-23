new Vue
  el: '#app'
  data: {
    posts: [],
    loading: {
      now: 0  # 読み込み進捗度
      total: 0  # 読み込み総数
    }
  }
  computed: {
    loading_rate: ->
      if 0 < @loading.total
        100 * @loading.now / @loading.total
      else
        0
  }
  filters: {
    round: Math.round
  }
  created: ->
    token = $("#token").text()
    owner = $("#owner").text()
    repo = $("#repo").text()
    branch = $("#branch").text()
    access_token = "?access_token=#{token}"
    root = "https://api.github.com"
    url = "#{root}/repos/#{owner}/#{repo}"
    ref = "heads/#{branch}"

    ajax_opt = {
      # ajax通信完了時に読み込みカウントをインクリメント
      complete: =>
        @loading.now += 1
    }

    _posts = []
    @loading.now = 0
    @loading.total = 2
    $.Deferred().resolve()
    # 最新のSHAを取得
    .then -> $.ajax "#{url}/git/refs/#{ref}#{access_token}", ajax_opt
    # ポストを列挙
    .then (ref)-> $.ajax "#{url}/git/trees/#{ref.object.sha}#{access_token}&recursive=1", ajax_opt
    .then (tree)->
      for item in tree.tree
        if result = item.path.match(/^_posts\/(.*\.md)/)
          console.log item
          _posts.push {
            path: item.path,
            name: result[1],
            draft: false
          }
        if result = item.path.match(/^_drafts\/(.*\.md)/)
          _posts.push {
            path: item.path,
            name: result[1],
            draft: true
          }
    .done =>
      @$set("posts", _posts)
      console.log "END"
      return
    return
