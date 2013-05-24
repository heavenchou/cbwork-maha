call index %1
sort d:\release\index\%1.tmp > d:\release\index\%1.tsp
call vert d:\release\index\%1.tsp
del d:\release\index\*.t?p

