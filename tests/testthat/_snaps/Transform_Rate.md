# rows with a denominator of 0 are removed

    Code
      row_removed
    Output
      # A tibble: 143 x 5
         GroupID GroupLevel Numerator Denominator Metric
         <chr>   <chr>          <int>       <dbl>  <dbl>
       1 0X035   Site              10         183 0.0546
       2 0X043   Site              13         187 0.0695
       3 0X101   Site              11         118 0.0932
       4 0X1224  Site               6          87 0.0690
       5 0X1236  Site              17         252 0.0675
       6 0X1257  Site               7          99 0.0707
       7 0X1399  Site               4          62 0.0645
       8 0X1645  Site               7         104 0.0673
       9 0X166   Site               3          30 0.1   
      10 0X1684  Site               9          84 0.107 
      # i 133 more rows

