" Max number of directory levels gf will traverse upwards
" to find a package.json file.
let g:find_file_max_levels = 5
" Default file names to try if gf is run on a directory rather than a specific file.
" Checked in order of appearance. Empty string to check for exact file match first.
let g:find_file_file_names = ["", ".js", "/index.js"]

function! FindFileJS(fname) abort
  let foundPackage = 0
  let levels = 0

  " Traverse up directories and attempt to find package.json
  while foundPackage != 1 && levels < g:find_file_max_levels
    echo levels
    let levels = levels + 1
    let foundPackage = filereadable(expand('%:p'.repeat(':h', levels)) . '/package.json')
  endwhile

  if foundPackage == 0
    echo "Failed to find package.json, try increasing the levels."
    return a:fname
  endif

  " Handy paths to package.json and parent dir
  let packagePath = globpath(expand('%:p'.repeat(':h', levels)), 'package.json')
  let packageDir = fnamemodify(packagePath, ':h')

  try
    let resolveDirs = json_decode(join(readfile(packagePath))).resolve
  catch
    echo "Couldn't find 'resolve' key in package.json"
    return a:fname
  endtry

  echo resolveDirs

  " Iterate over potential directories and search for the file
  for dir in resolveDirs
    let possiblePath = packageDir . "/" . dir . "/" . a:fname
    echo possiblePath

    for filename in g:find_file_file_names
      if filereadable(possiblePath . filename)
        return possiblePath . filename
      endif
    endfor
  endfor

  " echo "FindFileJS failed to find file specified."
  return a:fname
endfunction

 set includeexpr=FindFileJS(v:fname)
