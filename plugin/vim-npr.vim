" Max number of directory levels gf will traverse upwards
" to find a package.json file.
let g:vim_npr_max_levels = 5

" Default file names to try if gf is run on a directory rather than a specific file.
" Checked in order of appearance. Empty string to check for exact file match first.
let g:vim_npr_file_names = ["", ".js", "/index.js"]

" A list of file extensions that the plugin will actively work on.
let g:vim_npr_file_types = ["js", "jsx", "css", "coffee"]

" Default resolution directories if 'resolve' key is not found in
" package.json.
let g:vim_npr_default_dirs = ["src", "lib", "test", "public", "node_modules"]

function! VimNPRFindFile(fname) abort
  if index(g:vim_npr_file_types, expand("%:e")) == -1
    return '' " Don't run on filetypes that we don't support
  endif

  let l:foundPackage = 0
  let l:levels = 0

  " Traverse up directories and attempt to find package.json
  while l:foundPackage != 1 && l:levels < g:vim_npr_max_levels
    let l:levels = l:levels + 1
    let l:foundPackage = filereadable(expand('%:p'.repeat(':h', l:levels)) . '/package.json')
  endwhile

  if l:foundPackage == 0
    echo "Failed to find package.json, try increasing the levels by increasing g:vim_npr_max_levels variable."
    return a:fname
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
    let l:possiblePath = l:packageDir . "/" . dir . "/" . a:fname

    echo l:possiblePath

    for filename in g:vim_npr_file_names
      if filereadable(possiblePath . filename)
        return possiblePath . filename
      endif
    endfor
  endfor

  echo "VimNPR failed to find file specified."
  return a:fname
endfunction

" Unmap any user mapped gf functionalities. This is to restore gf
" when hijacked by another plugin e.g. vim-node
autocmd FileType javascript silent! unmap <buffer> gf

" Override includeexpr for Javascript buffer.
" By default vim-node will try to take control.
"
" au[tocmd] [group] {event} {pat} [nested] {cmd}
autocmd FileType javascript,*.css set includeexpr=VimNPRFindFile(v:fname)
