" Set it to 0 to to stop talking to Jimmy.
if !exists('g:JimmyEnabled')
  let g:JimmyEnabled = 1
end

" When was the last time a message was sent to Jimmy. We calculate a delay
" based on it.
let g:JimmyKeyPressDelay = 200
""
let g:JimmyKeyPressTimer = 0
" When we open the editor, it has to have a name so that Jimmy knows who's
" who.
let g:editorName = localtime()

" EDITOR FUNCTIONS
"
function! MyName()
  return "[my-name:" . g:editorName . "]"
endfunction

" FLOW WITH JIMMY FUNCTIONS
"

" TODO - Once I know how to deal with job_start I'll use it and remove
" AsyncRun! https://flukus.github.io/2016/04/15/2016_04_15_Background-Builds-with-Vim-8/
"
" TODO - adds messages to a queue instead of making direct calls to
" TellJimmy().
"
" Basically, if a job is running and a new one was started, it will error out.
" However, if we attempt to send the same message again with a timer, we will
" be able to hold one (1) message for later. In the advent we have many
" messages to be sent later, we won't be able to do it.
"
function! TellJimmy(message)
  if g:JimmyEnabled == 1
    exec ":AsyncRun! ruby -I/Users/kurko/www/jimmy/core/lib /Users/kurko/www/jimmy/core/bin/server-test " . a:message
  endif
endfunction

function! TellJimmyKeyWasPressed(timer)
  let l:message = []
  call add(l:message, MyName())
  call add(l:message, KeyValueInMessage("dir",    getcwd()))
  call add(l:message, KeyValueInMessage("file",   expand("%")))
  call add(l:message, KeyValueInMessage("when",   localtime()))
  call add(l:message, KeyValueInMessage("action", "key-pressed"))

  if g:asyncrun_status == "running"
    call TimedKeyPressedForJimmy()
  else
    call TellJimmy(join(l:message, ""))
  endif
endfunction

function! JimmyFinishedSpeakingAsyncRun()
  let list = getqflist()
  let l:newList = []

  " TODO - for debugging
  "for i in list
  "  let l:newList = l:newList + [{"text": "Received: " . i.text}]
  "endfor

  "call setqflist(l:newList, "a")
endfunction

function! JimmyStartUnderstandingMessage(message)
endfunction

" MESSAGE FORMATTING AND CONFIGURATION
"
function! KeyValueInMessage(key, value)
  return "[".a:key.":".a:value."]"
endfunction

" ENTRYPOINT
"
function! EditorOpened()
  let state = "[state:opened]"
  let myName = "[my-name:" . g:editorName . "]"
  call TellJimmy("[vim-editor]" . state . myName)
endfunction
call EditorOpened()

function! TimedKeyPressedForJimmy()
  " TODO - should use `g:asyncrun_status` ('running', 'success' or 'failure') to
  " figure out whether to run jimmy or not.
  "
  " https://github.com/skywind3000/asyncrun.vim/issues/26#issuecomment-269092405
  call timer_stop(g:JimmyKeyPressTimer)
  let g:JimmyKeyPressTimer = timer_start(g:JimmyKeyPressDelay, "TellJimmyKeyWasPressed")
endfunction

" AUTOLOAD
"
augroup Jimmy
  autocmd!

  autocmd User AsyncRunStop call JimmyFinishedSpeakingAsyncRun()
  autocmd TextChanged,TextChangedI * :call TimedKeyPressedForJimmy()
augroup END
