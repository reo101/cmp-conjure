if exists('g:loaded_compe')
  packadd conjure
  lua require'compe'.register_source('conjure', require'compe_conjure')
endif
