# rows with a denominator of 0 are removed

    Code
      row_removed
    Output
      # A tibble: 144 x 5
         GroupID GroupLevel Numerator Denominator Metric
         <chr>   <chr>          <int>       <dbl>  <dbl>
       1 0X101   Site              16         197 0.0812
       2 0X1109  Site               2          32 0.0625
       3 0X1137  Site               8         196 0.0408
       4 0X1257  Site              17         163 0.104 
       5 0X1548  Site               5          93 0.0538
       6 0X155   Site               2          13 0.154 
       7 0X1750  Site              23         336 0.0685
       8 0X180   Site              30         281 0.107 
       9 0X1800  Site               3          24 0.125 
      10 0X1839  Site              20         190 0.105 
      # i 134 more rows

