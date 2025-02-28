
### Extract data with ingest tool by running this:
```bash
python3 -m dcpy.cli lifecycle ingest dpr_forever_wild -s
```

### Ingest tool in action
```mermaid
flowchart LR
  B[Raw data]
  n1@{ shape: "tri", label: "Local File" } -->  B
  n2@{ shape: "tri", label: "API" } -->  B
  n3@{ shape: "tri", label: "Open Data" } --> |Extract to local machine| B
  n4@{ shape: "tri", label: "ArcGIS Server" }--> B
  n5@{ shape: "tri", label: "S3" } -->  B
  
  B -->|Convert to parquet| C[init.parquet]

  %%C --> D{Pre-processing steps specified?}
  %%D -- Yes --> E[Apply pre-processing steps]
  %%E --> F[dataset_id.parquet]
  %%D -- No --> F

  E[dataset_id.parquet]
  C -->|No change| E
  C -->|Apply pre-processing steps| E
```

### Output files
- `config.json`: this is a metadata file about data and ingestion process. 
- `init.parquet`: raw data in parquet format
- `<dataset_id>.<format extension>`: raw data. Example: `dpr_forever_wild.zip`.
- `<dataset_id>.parquet`: output data. Example: `dpr_forever_wild.parquet`. If pre-processing steps were not specified in dataset template, then this file will be the same as `init.parquet`

### Instruction how to create a template
TODO
