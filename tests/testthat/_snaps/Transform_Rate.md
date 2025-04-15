# rows with a denominator of 0 are removed

    Code
      row_removed
    Output
      # A tibble: 142 x 5
         GroupID GroupLevel Numerator Denominator Metric
         <chr>   <chr>          <int>       <dbl>  <dbl>
       1 0X025   Site              14         166 0.0843
       2 0X031   Site               7          51 0.137 
       3 0X040   Site               2          24 0.0833
       4 0X043   Site               4          48 0.0833
       5 0X101   Site              11         128 0.0859
       6 0X1257  Site               8         156 0.0513
       7 0X1355  Site              13         145 0.0897
       8 0X1384  Site              17         199 0.0854
       9 0X1523  Site              12          98 0.122 
      10 0X157   Site               4          46 0.0870
      # i 132 more rows

