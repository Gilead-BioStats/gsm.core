# rows with a denominator of 0 are removed

    Code
      row_removed
    Output
      # A tibble: 145 x 5
         GroupID GroupLevel Numerator Denominator Metric
         <chr>   <chr>          <int>       <dbl>  <dbl>
       1 0X101   Site              15         125 0.12  
       2 0X111   Site              12          95 0.126 
       3 0X1146  Site              18         285 0.0632
       4 0X1189  Site              18         155 0.116 
       5 0X1257  Site              14         212 0.0660
       6 0X1339  Site               4          76 0.0526
       7 0X1382  Site               4          49 0.0816
       8 0X1562  Site              14         140 0.1   
       9 0X1568  Site               2          20 0.1   
      10 0X1712  Site               4          18 0.222 
      # i 135 more rows

