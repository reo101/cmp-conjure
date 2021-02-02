# compe-conjure
compe-nvim source for conjure

## Usage 

Make sure that compe-nvim is loaded.

```vim
let g:compe.source.conjure = v:true
```

```clojure
((. (require :compe) :setup) 
 {:source 
   {:conjure true})
```

```lua
require'compe'.setup {
  source = {
      conjure = true
    }
}
```
