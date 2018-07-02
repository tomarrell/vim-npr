" Vim-NPR
" Max number of directory levels gf will traverse upwards
" to find a package.json file.
let g:vim_npr_max_levels = 5

" Default file names to try if gf is run on a directory rather than a specific file.
" Checked in order of appearance. Empty string to check for exact file match first.
" The final two are specifically for matching libraries which define their UMD
" module resolution in their package.json, and these are the most common.
let g:vim_npr_file_names = ["", ".js", "/index.js", "/index.jsx", "/src/index.js", "/lib/index.js"]

" A list of file extensions that the plugin will actively work on.
let g:vim_npr_file_types = ["js", "jsx", "css", "coffee"]

" Default resolution directories if 'resolve' key is not found in package.json.
let g:vim_npr_default_dirs = ["src", "lib", "test", "public", "node_modules"]

function! VimNPRFindFile(cmd) abort
  if index(g:vim_npr_file_types, expand("%:e")) == -1
    return s:print_error("(Error) VimNPR: incorrect file type for to perform resolution within. Please raise an issue at github.com/tomarrell/vim-npr.") " Don't run on filetypes that we don't support
  endif

  " Get file path pattern under cursor
  let l:cfile = expand("<cfile>")

  " Iterate over potential directories and search for the file
  for filename in g:vim_npr_file_names
    let l:possiblePath = expand("%:p:h") . '/' . l:cfile . filename

    if filereadable(l:possiblePath)
      return s:edit_file(l:possiblePath, a:cmd)
    endif
  endfor

  let l:foundPackage = 0
  let l:levels = 0

  " Traverse up directories and attempt to find package.json
  while l:foundPackage != 1 && l:levels < g:vim_npr_max_levels
    let l:levels = l:levels + 1
    let l:foundPackage = filereadable(expand('%:p'.repeat(':h', l:levels)) . '/package.json')
  endwhile

  if l:foundPackage == 0
    return s:print_error("(Error) VimNPR: Failed to find package.json, try increasing the levels by increasing g:vim_npr_max_levels variable.")
  endif

  " Handy paths to package.json and parent dir
  let l:packagePath = globpath(expand('%:p'.repeat(':h', l:levels)), 'package.json')
  let l:packageDir = fnamemodify(l:packagePath, ':h')

  try
    let l:resolveDirs = json_decode(join(readfile(l:packagePath))).resolve
  catch
    echo "Couldn't find 'resolve' key in package.json"
    let l:resolveDirs = g:vim_npr_default_dirs
  endtry

  " Iterate over potential directories and search for the file
  for dir in l:resolveDirs
    let l:possiblePath = l:packageDir . "/" . dir . "/" . l:cfile

    for filename in g:vim_npr_file_names
      if filereadable(possiblePath . filename)
        return s:edit_file(possiblePath . filename, a:cmd)
      endif
    endfor
  endfor

  " Nothing found, print resolution error
  return s:print_error("(Error) VimNPR: Failed to sensibly resolve file in path. If you believe this to be an error, please log an error at github.com/tomarrell/vim-npr.")
endfunction

function! s:edit_file(path, cmd)
  exe "edit" . a:cmd . " " . a:path
endfunction

function! s:print_error(error)
  echohl ErrorMsg
  echomsg a:error
  echohl NONE
  let v:errmsg = a:error
endfunction

" Unmap any user mapped gf functionalities. This is to restore gf
" when hijacked by another plugin e.g. vim-node
autocmd FileType javascript silent! unmap <buffer> gf
autocmd FileType javascript silent! unmap <buffer> <C-w>f
autocmd FileType javascript silent! unmap <buffer> <C-w><C-f>

" Automap gf when entering JS/css file types
autocmd BufEnter *.js,*.jsx,*.css,*.coffee nmap <buffer> gf :call VimNPRFindFile("")<CR>
