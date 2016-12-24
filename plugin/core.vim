

" When was the last time a message was sent to Jimmy. We calculate a delay
" based on it.
let g:JimmyKeyPressDelay = 2000
""
let g:JimmyKeyPressTimer = 0

function! JimmyStartCommunications(timer)
  exec ":AsyncRun! ruby -I/Users/kurko/www/jimmy/core/lib /Users/kurko/www/jimmy/core/bin/server-test " . strftime("%c")

  " TODO - Once I know how to deal with job_start I'll use it and remove
  " AsyncRun!
  "
  " https://flukus.github.io/2016/04/15/2016_04_15_Background-Builds-with-Vim-8/
  "
  "let g:jimmyBuffer = bufnr('jimmy_buffer', 1)
  "let cmd = "ruby -I/Users/kurko/www/jimmy/core/lib /Users/kurko/www/jimmy/core/bin/server-test " . strftime("%c")
  "let job = job_start(cmd, {'out_io': 'buffer', 'out_name': 'jimmy_buffer', 'out_cb': 'JimmyReceiveMessage', 'exit_cb': 'JimmyJobExitHandler'})
endfunction

function! JimmyFinishedSpeakingAsyncRun()
  let list = getqflist()
  for i in list
    exec "echom 1"
  endfor
endfunction

function! JimmyReceiveMessage(job, message)
endfunction

function! JimmyJobExitHandler(job, status)
endfunction

function! JimmyStartUnderstandingMessage(message)

endfunction

" ENTRYPOINT
"
function! KeyPressedForJimmy(input_string)
  " TODO - should use `g:asyncrun_status` ('running', 'success' or 'failure') to
  " figure out whether to run jimmy or not.
  "
  " https://github.com/skywind3000/asyncrun.vim/issues/26#issuecomment-269092405
  call timer_stop(g:JimmyKeyPressTimer)
  let g:JimmyKeyPressTimer = timer_start(g:JimmyKeyPressDelay, "JimmyStartCommunications")
endfunction

augroup Jimmy
  autocmd!

  autocmd User AsyncRunStop :call JimmyFinishedSpeakingAsyncRun()
  autocmd CursorMoved  * :call KeyPressedForJimmy("string")
augroup END
