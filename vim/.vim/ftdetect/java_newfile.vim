" Injects class header and package directive when
" creatinga new class

autocmd BufNewFile *.java call InsertJavaPackage()
function! InsertJavaPackage()
    call InsertJavaPackageWithType("class")
endfunction

function! InsertJavaPackageWithType(type)
  let filename = expand("%")
  let filename = substitute(filename, "\.java$", "", "")
  let dir = getcwd() . "/" . filename
  let dir = substitute(dir, "^.*\/src\/", "", "")
  let dir = substitute(dir, "\/[^\/]*$", "", "")
  let dir = substitute(dir, "\/", ".", "g")
  let filename = substitute(filename, "^.*\/", "", "")
  let dir = "package " . dir . ";"
  let result = append(0, dir)
  let result = append(1, "")
  let result = append(2, "public class " . filename . " {")
  let result = append(4, "}")
endfunction


