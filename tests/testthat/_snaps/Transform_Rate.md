# rows with a denominator of 0 are removed

    Code
      row_removed
    Output
      # A tibble: 142 x 5
         GroupID GroupLevel Numerator Denominator Metric
         <chr>   <chr>          <int>       <dbl>  <dbl>
       1 0X019   Site               4          66 0.0606
       2 0X101   Site              19         168 0.113 
       3 0X1137  Site              18         250 0.072 
       4 0X1152  Site              15         102 0.147 
       5 0X1257  Site              19         172 0.110 
       6 0X1548  Site               9         121 0.0744
       7 0X1628  Site               2          24 0.0833
       8 0X1745  Site               8          64 0.125 
       9 0X1750  Site              18         341 0.0528
      10 0X1759  Site              12          46 0.261 
      # i 132 more rows

