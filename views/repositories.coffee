new Vue
  el: '#app'
  data: {
    repositories: []
  }
  created: ()->
    token = $("#token").text()
    access_token = "?access_token=#{token}"
    root = "https://api.github.com"

    jekyll_repos = []
    # リポジトリを列挙
    $.Deferred().resolve().then ()-> $.get "#{root}/user/repos#{access_token}"
    .then (repos)=>
      # 各リポジトリがJekyllか判定
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
        console.log @$data
        return
      return
    return
