# cmp-conjure
nvim-cmp source for conjure

## Setup 

Make sure that nvim-cmp is loaded.

```clojure
((. (require :cmp) :setup)
  {:sources
    {1 
      {:name :conjure}}})	
```

```lua
require("cmp").setup({
    sources = {
        { name = "conjure" },
    },
})
```
