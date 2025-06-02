# gsm.core v1.1.1

This patch release fixes a few CLI messages from RunStep(), adds new "timestamp" and "logical" `types` to mapping specs, and addresses erroneous warning messages in the testing suite. It also prepares the package for CRAN release 


# gsm.core v1.1.0

This minor release adds PK analysis functionality and updates package data to use `{gsm.datasim}`. Specifically:
- `lSource` package data has been updated to include PK data
- `analytics` and `reporting` package data is now generated using `{gsm.datasim}` simulated data as the source data.
- Updates to the `Flag()` and `Summarize()` functions to make thresholds more flexible. 
The `Flag_Accrual()` helper function now allows thresholds to be based on the Numerator, Denominator, or Difference between the two.

For more details on the changes and new features, please refer to the documentation and pull requests linked to this release.

# gsm.core v1.0.0

We are excited to announce the first major release of the `gsm.core` package, which serves as the backbone of the GSM pipeline. This package provides the analytics framework for constructing metrics and includes utility functions to execute workflows. 

### Key Features and Updates:
- **Integration with Other gsm Packages:**  
  The package is designed to seamlessly integrate with other GSM modules (e.g., `gsm.mapping`, `gsm.reporting`, `gsm.kri`), ensuring smooth data flow and interoperability across the pipeline. It serves as the central hub for analytics and workflow execution.

### Other Updates:
- Bug fixes and minor improvements to the existing utility functions.

For more details on the changes and new features, please refer to the documentation and pull requests linked to this release.
