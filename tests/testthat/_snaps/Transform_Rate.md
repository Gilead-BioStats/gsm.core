# rows with a denominator of 0 are removed

    Code
      row_removed
    Output
      # A tibble: 145 x 5
         GroupID GroupLevel Numerator Denominator Metric
         <chr>   <chr>          <int>       <dbl>  <dbl>
       1 0X101   Site               8         131 0.0611
       2 0X1040  Site               2          16 0.125 
       3 0X1231  Site               6          83 0.0723
       4 0X1257  Site              11         115 0.0957
       5 0X1268  Site               6         161 0.0373
       6 0X1280  Site               8          68 0.118 
       7 0X1321  Site              14         138 0.101 
       8 0X1376  Site              30         301 0.0997
       9 0X1543  Site               2          15 0.133 
      10 0X1581  Site              11         129 0.0853
      # i 135 more rows

