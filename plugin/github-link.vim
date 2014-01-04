" github-link - Link to a specific line on github
" Author:   Ethan Soergel (github.com/esoergel/)
" HomePage: https://github.com/esoergel/vim-github-link
" Credit:   This plugin copies extensively from vim-github-comment by mmozuras
"           (https://github.com/mmozuras/vim-github-comment)


com! GHlink call GHlink()


function GHlink()
  let url = s:GetURL()
  call s:OpenBrowser(url)
endfunction


function! s:GetURL()
  let repo = s:GitHubRepository()
  let path = s:GetRelativePathOfBufferInRepository()
  let branch = "master"
  let line = line(".")
  return "https://github.com/".repo."/blob/".branch."/".path."#L".line
endfunction


function! s:GitHubRepository()
  let cmd = 'git ls-remote --get-url'
  let remote = system(cmd)

  let name = split(remote, 'git://github\.com/')[0]
  let name = split(name, 'git@github\.com:')[0]
  let name = split(name, '\.git')[0]

  return name
endfunction


function! s:GetRelativePathOfBufferInRepository()
  let buffer_path = expand("%:p")
  let git_dir = s:GetGitTopDir()."/"

  return substitute(buffer_path, git_dir, "", "")
endfunction


function! s:GetGitTopDir()
  let buffer_path = expand("%:p")
  let buf = split(buffer_path, "/")

  while len(buf) > 0
    let path = "/".join(buf, "/")

    if empty(finddir(path."/.git"))
      call remove(buf, -1)
    else
      return path
    endif
  endwhile

  return ""
endfunction

function! s:OpenBrowser(url)
  if has('win32') || has('win64')
    let cmd = '!start rundll32 url.dll,FileProtocolHandler '.shellescape(a:url)
    silent! exec cmd
  elseif has('mac') || has('macunix') || has('gui_macvim')
    let cmd = 'open '.shellescape(a:url)
    call system(cmd)
  elseif executable('xdg-open')
    let cmd = 'xdg-open '.shellescape(a:url)
    call system(cmd)
  elseif executable('firefox')
    let cmd = 'firefox '.shellescape(a:url).' &'
    call system(cmd)
  else
    echohl WarningMsg | echomsg "That's weird. It seems that you don't have a web browser." | echohl None
  end
endfunction
