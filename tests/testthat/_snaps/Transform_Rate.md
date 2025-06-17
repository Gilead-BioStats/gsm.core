# rows with a denominator of 0 are removed

    Code
      row_removed
    Output
      # A tibble: 143 x 5
         GroupID GroupLevel Numerator Denominator Metric
         <chr>   <chr>          <int>       <dbl>  <dbl>
       1 0X101   Site              17         196 0.0867
       2 0X1137  Site               8          78 0.103 
       3 0X1257  Site              29         182 0.159 
       4 0X1333  Site              13         182 0.0714
       5 0X1426  Site               1          17 0.0588
       6 0X1595  Site               2          12 0.167 
       7 0X1750  Site              24         252 0.0952
       8 0X180   Site              29         303 0.0957
       9 0X1839  Site               6          64 0.0938
      10 0X1910  Site              19         253 0.0751
      # i 133 more rows

