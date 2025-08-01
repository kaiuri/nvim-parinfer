" Copyright (C) 2021 Gregory Anders
"
" SPDX-License-Identifier: GPL-3.0-or-later
"
" This program is free software: you can redistribute it and/or modify
" it under the terms of the GNU General Public License as published by
" the Free Software Foundation, either version 3 of the License, or
" (at your option) any later version.
"
" This program is distributed in the hope that it will be useful,
" but WITHOUT ANY WARRANTY; without even the implied warranty of
" MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
" GNU General Public License for more details.
"
" You should have received a copy of the GNU General Public License
" along with this program.  If not, see <https://www.gnu.org/licenses/>.

function! parinfer#log(...) abort
    if a:0 > 0
        let g:parinfer_logfile = a:1
        echomsg 'Parinfer is now logging to '.a:1
    else
        unlet! g:parinfer_logfile
        echomsg 'Parinfer is no longer logging'
    endif
endfunction

function! parinfer#enable(bang, enable) abort
    if a:bang
        let g:parinfer_enabled = a:enable
        echomsg 'Parinfer ' .. (a:enable ? 'enabled' : 'disabled') .. ' globally'
    else
        let b:parinfer_enabled = a:enable
        echomsg 'Parinfer ' .. (a:enable ? 'enabled' : 'disabled') .. ' in the current buffer'
    endif
    doautocmd <nomodeline> User Parinfer
endfunction

function! parinfer#toggle(bang) abort
    if a:bang
        call parinfer#enable(1, !get(g:, 'parinfer_enabled', v:true))
    else
        call parinfer#enable(0, !get(b:, 'parinfer_enabled', get(g:, 'parinfer_enabled', v:true)))
    endif
endfunction

function! parinfer#init() abort
    if &previewwindow || &buftype ==# 'prompt'
        return
    endif

    command! -buffer ParinferStats lua parinfer.stats()

    let b:parinfer_enabled = get(g:, 'parinfer_enabled', v:true)

    lua parinfer.enter_buffer()

    doautocmd <nomodeline> User Parinfer

    augroup parinfer
        autocmd! TextChanged,TextChangedI,TextChangedP <buffer> call v:lua.parinfer.text_changed(+expand("<abuf>"))
        autocmd! CursorMoved,CursorMovedI <buffer> call v:lua.parinfer.cursor_moved(+expand("<abuf>"))
    augroup END

    if !get(b:, 'parinfer_no_maps', get(g:, 'parinfer_no_maps', 0))
        if mapcheck('<Tab>', 'i') ==# ''
            imap <buffer> <Tab> <Plug>(parinfer-tab)
        endif

        if mapcheck('<S-Tab>', 'i') ==# ''
            imap <buffer> <S-Tab> <Plug>(parinfer-backtab)
        endif
    endif
endfunction

lua require('parinfer.init')
