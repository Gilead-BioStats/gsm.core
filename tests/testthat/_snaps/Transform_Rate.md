# rows with a denominator of 0 are removed

    Code
      row_removed
    Output
      # A tibble: 137 x 5
         GroupID GroupLevel Numerator Denominator Metric
         <chr>   <chr>          <int>       <dbl>  <dbl>
       1 0X008   Site               0          24 0     
       2 0X1012  Site              62        3596 0.0172
       3 0X1083  Site               4         179 0.0223
       4 0X109   Site              14        1106 0.0127
       5 0X1179  Site               4          94 0.0426
       6 0X1212  Site              11         240 0.0458
       7 0X1256  Site              42        1817 0.0231
       8 0X1270  Site              39        2367 0.0165
       9 0X1290  Site               4         114 0.0351
      10 0X1411  Site              29        2092 0.0139
      # i 127 more rows

