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
    loading_rate: ()->
      if 0 < @loading.total
        100 * @loading.now / @loading.total
      else
        0
  }
  filters: {
    round: Math.round
  }
  created: ()->
    token = $("#token").text()
    access_token = "?access_token=#{token}"
    root = "https://api.github.com"

    $(document).ajaxSuccess ()=>
      @loading.now += 1

    @loading.now = 0
    @loading.total = 0
    jekyll_repos = []
    # リポジトリを列挙
    $.Deferred().resolve()
    .then ()-> $.get "#{root}/user/repos#{access_token}"
    .then (repos)=>
      # 各リポジトリがJekyllか判定
      @loading.total += repos.length * 2
      defer = $.Deferred().resolve()
      _.each repos, (repo)->
        url = repo.url
        name = repo.full_name
        # 最新のコミットのSHAを取得
        defer = defer.then ()-> $.get "#{url}/branches/master#{access_token}"
        # ツリーを取得
        .then (branch)-> $.get "#{url}/git/trees/#{branch.commit.sha}#{access_token}"
        # ツリーからJekyllのリポジトリか判定する
        .then (trees)->
          has_posts = _.any(trees.tree, (item)-> item.path == "_posts")
          has_drafts = _.any(trees.tree, (item)-> item.path == "_drafts")
          if has_posts and has_drafts
            console.log "#{name} is jekyll"
            jekyll_repos.push repo
          else
            console.log "#{name} is not jekyll"
          return
      defer.done ()=>
        @$set("repositories", jekyll_repos)
        console.log "END"
        return
      return
    return
