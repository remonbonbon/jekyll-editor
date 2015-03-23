new Vue
  el: '#app'
  data: {
    repositories: [],
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
    access_token = "?access_token=#{token}"
    root = "https://api.github.com"

    ajax_opt = {
      # ajax通信完了時に読み込みカウントをインクリメント
      complete: =>
        @loading.now += 1
    }

    @loading.now = 0
    @loading.total = 1
    jekyll_repos = []
    # リポジトリを列挙
    $.Deferred().resolve()
    .then -> $.ajax "#{root}/user/repos#{access_token}", ajax_opt
    .then (repos)=>
      # 各リポジトリがJekyllか判定
      defer = $.Deferred().resolve()
      @loading.total += repos.length
      _.each repos, (repo)->
        url = repo.url
        full_name = repo.full_name

        # ルートディレクトリに_postsディレクトリと_draftsディレクトリがあるか確認
        defer = defer.then -> $.ajax "#{url}/contents/#{access_token}", ajax_opt
        .then (contents)->
          for item in contents
            has_posts = true if item.name == "_posts"
            has_drafts = true if item.name == "_drafts"
          if has_posts and has_drafts
            jekyll_repos.push repo
            console.log "#{full_name} is jekyll"
          else
            console.log "#{full_name} is not jekyll"
          return
      defer.done =>
        @$set("repositories", jekyll_repos)
        console.log "END"
        return
      return
    return
