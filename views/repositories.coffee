new Vue {
  el: '#app',
  data: {
    repositories: []
  },
  created: ()->
    token = $("#token").text()
    access_token = "?access_token=#{token}"
    root = "https://api.github.com"

    repositories = []
    $.Deferred().resolve().then(()->
      # リポジトリを列挙
      return $.ajax {
        url: "#{root}/user/repos#{access_token}",
        success: (res)->
          repositories = res
          return
      }
    ).then(()->
      # 各リポジトリがJekyllか判定
      defer = $.Deferred().resolve()
      _.each(repositories, (repo)->
        url = repo.url
        name = repo.full_name
        sha = ""
        tree = []
        defer = defer.then(()->
          # 最新のコミットのSHAを取得
          return $.ajax {
            url: "#{url}/branches/master#{access_token}",
            success: (res)->
              console.log name, "get SHA"
              sha = res.commit.sha
              return
          }
        ).then(()->
          # ツリーを取得
          return $.ajax {
            url: "#{url}/git/trees/#{sha}#{access_token}",
            success: (res)->
              console.log name, "get tree"
              tree = res.tree
              return
          }
        ).then(()->
          # ツリーからJekyllのリポジトリか判定する
          has_posts = _.any(tree, (item)-> item.path == "_posts")
          has_drafts = _.any(tree, (item)-> item.path == "_drafts")
          console.log has_posts, has_drafts
          if has_posts and has_drafts
            console.log "is jekyll"
            # repositories.push {
              # url: url,
              # name: name,
              # description: 
            # }
          return
        )
        return
      )
      return
    )
    return
}
