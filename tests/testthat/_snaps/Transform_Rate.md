# rows with a denominator of 0 are removed

    Code
      row_removed
    Output
      # A tibble: 144 x 5
         GroupID GroupLevel Numerator Denominator Metric
         <chr>   <chr>          <int>       <dbl>  <dbl>
       1 0X040   Site              24         273 0.0879
       2 0X087   Site               5          35 0.143 
       3 0X098   Site               8         128 0.0625
       4 0X1011  Site               3          31 0.0968
       5 0X1133  Site               6         106 0.0566
       6 0X1312  Site               9         163 0.0552
       7 0X1425  Site              17         130 0.131 
       8 0X1582  Site              14          76 0.184 
       9 0X1598  Site              74         999 0.0741
      10 0X1640  Site               7          61 0.115 
      # i 134 more rows

