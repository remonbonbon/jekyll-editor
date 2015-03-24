new Vue
  el: '#app'
  data: {
    posts: []
  }
  created: ->
    token = $("#token").text()
    owner = $("#owner").text()
    repo = $("#repo").text()
    branch = $("#branch").text()
    access_token = "?access_token=#{token}"
    root = "https://api.github.com"
    url = "#{root}/repos/#{owner}/#{repo}"

    _posts = []
    # _posts配下と_drafts配下を取得
    $.when(
      $.ajax "#{url}/contents/_posts#{access_token}&ref=#{branch}"
      .then (res)->
        for file in res
          _posts.push {path: file.path, name: file.name, draft: false},
      $.ajax "#{url}/contents/_drafts#{access_token}&ref=#{branch}"
      .then (res)->
        for file in res
          _posts.push {path: file.path, name: file.name, draft: true}
    ).always ()=>
      @$set("posts", _posts)
      console.log "END"
