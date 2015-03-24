new Vue
  el: '#app'
  data: {
    header: "",
    content: ""
  }
  filters: {
    marked: marked
  }
  created: ->
    token = $("#token").text()
    owner = $("#owner").text()
    repo = $("#repo").text()
    branch = $("#branch").text()
    directory = $("#directory").text()
    filename = $("#filename").text()
    access_token = "?access_token=#{token}"
    root = "https://api.github.com"
    url = "#{root}/repos/#{owner}/#{repo}"

    $.ajax "#{url}/contents/#{directory}/#{filename}#{access_token}&ref=#{branch}"
    .then (res)=>
      content = Base64.decode res.content
      # ファイル冒頭の---で囲まれた部分を取得する
      @content = content.replace /^---[\r\n]{1,2}[\s\S]*?[\r\n]{1,2}---[\r\n]{0,2}/, ""
      @header = RegExp.lastMatch
